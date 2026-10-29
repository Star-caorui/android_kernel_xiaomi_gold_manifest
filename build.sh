#!/bin/bash
# Build gold's vendor kernel modules from the synced sources the way stock's were built, for comparing them with
# stock's. Run from anywhere in a tree synced from default.xml; see verify/README.md.
#
#   CLANG    clang-r510928's directory (default: prebuilts/clang/host/linux-x86/clang-r510928, as default.xml syncs)
#   KBT      kernel-build-tools' linux-x86 directory (default: prebuilts/kernel-build-tools/linux-x86)
#   OUT      output directory (default: out/ in the synced tree)
#   JOBS     parallel jobs (default: all CPUs)
#
# Writes every module to $OUT/modules/, the device tree blob to $OUT/dtb/gold.dtb, the overlay to $OUT/dtb/dtbo.img and
# the build logs to $OUT/logs/.
set -u
R=$(cd "$(dirname "$0")/.." && pwd)
CLANG=${CLANG:-$R/prebuilts/clang/host/linux-x86/clang-r510928}; KBT=${KBT:-$R/prebuilts/kernel-build-tools/linux-x86}
OUT=${OUT:-$R/out}; JOBS=${JOBS:-$(nproc)}
K=$R/kernel-6.6; KO=$OUT/KERNEL_OBJ
DM=kernel_device_modules-6.6; HQ=vendor/huaqin/kernel_modules/gold; VM=vendor/mediatek/kernel_modules
export PATH=$CLANG/bin:$PATH LD_LIBRARY_PATH=$KBT/lib64
# a clean start for the external modules, so that no module of an earlier build is picked up
rm -rf $OUT/$DM $OUT/vendor $OUT/modules $OUT/logs; mkdir -p $KO $OUT/logs
FAIL=0; log() { echo "$(date +%T) $*" | tee -a $OUT/logs/build.txt; }
# stock's release string: its modules name the commit of the kernel tree they were built in (4d05d8779bfd, not
# public); the kernel built here is the public one of the GKI kernel on the phone. The kernel's own modules carry
# that commit as their scmversion too; the external modules carry none.
SCM=g4d05d8779bfd
REL=6.6.118-android15-8-$SCM-4k
FL=(ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1 KERNELRELEASE=$REL
  KCONFIG_EXT_PREFIX=../$DM/ DEVICE_MODULES_REL_DIR=../$DM DEVICE_MODULES_PATH=$K/../$DM
  DEVCIE_MODULES_INCLUDE=-I$K/../$DM/include MTK_KERNEL_MODULES_PATH=$K/../$VM
  MTK_KERNEL_MODULES_OUT=$OUT/$VM PAHOLE=$KBT/bin/pahole)
# The directories are given from the kernel's (kernel-6.6/../x), as MediaTek's build does: the kernel maps its own
# directory out of the paths it compiles into the modules (__FILE__), so they read ../x/... as stock's do.
mk() { make -j$JOBS "${FL[@]}" -C $K O=$KO "$@"; }

# the kernel's configuration as LineageOS's kernel.mk makes it: gki_defconfig, then each fragment merged in turn
cp $K/arch/arm64/configs/gki_defconfig $KO/.config; mk olddefconfig > $OUT/logs/config.log 2>&1
for c in mgk_64_k66.config mt6833_overlay.config gold.config; do
  (cd $KO && $K/scripts/kconfig/merge_config.sh -m -O $KO $KO/.config $R/$DM/kernel/configs/$c) >> $OUT/logs/config.log 2>&1
  mk olddefconfig >> $OUT/logs/config.log 2>&1
done
mk prepare >> $OUT/logs/config.log 2>&1
log "config: $(grep -c '=' $KO/.config) options, release $(cat $KO/include/config/kernel.release)"
# the kernel itself, for its symbols and the base of the modules' BTF (the phone runs Google's GKI build)
mk Image modules module_scmversion=$SCM > $OUT/logs/kernel.log 2>&1; log "kernel: rc $?"

# the device tree blob of vendor_boot (mt6833.dts) and the overlay of dtbo (gold.dts): each built as the kernel's
# cmd_dtc builds a dtb, with the kernel's dtc and the include paths of the device modules' dts Makefile, and packed
# in an Android DT table, as stock's are
D=$R/$DM/arch/arm64/boot/dts/mediatek; DI="$K/scripts/dtc/include-prefixes $R/$DM/include $R/$DM/arch/arm64/boot/dts $D"
rm -rf $OUT/dtb; mkdir -p $OUT/dtb; : > $OUT/logs/dtb.log
dt() {  # dt <dts> <blob> <image>
  clang -E -nostdinc $(printf -- '-I%s ' $DI) -undef -D__DTS__ -x assembler-with-cpp -o $OUT/dtb/$1.tmp $D/$1 \
      >> $OUT/logs/dtb.log 2>&1 &&
    $KO/scripts/dtc/dtc -q -O dtb -o $OUT/dtb/$2 -b 0 $(printf -- '-i%s ' $D $DI) -@ $OUT/dtb/$1.tmp \
      >> $OUT/logs/dtb.log 2>&1 &&
    $KBT/bin/mkdtboimg create $OUT/dtb/$3 --page_size=2048 $OUT/dtb/$2 >> $OUT/logs/dtb.log 2>&1
  local rc=$?; [ $rc -eq 0 ] || FAIL=1; log "$3: rc $rc"
}
dt mt6833.dts mt6833.dtb gold.dtb
dt gold.dts gold.dtbo dtbo.img

ext() {  # ext <directory> [make arguments]: one external module directory, as kernel.mk builds it
  local m=$1; shift
  # __ANDROID_COMMON_KERNEL__: the Android common kernel's build.config.common defines it for every compilation;
  # of the sources built here only Mali's look at it (the kernel's own do not, so the kernel is built without it).
  # stock's external modules carry no BTF and no scmversion (which a git checkout of the sources would give
  # them); the kernel's own carry both
  make -j$JOBS -k "${FL[@]}" CONFIG_DEBUG_INFO_BTF_MODULES= CONFIG_MODULE_SCMVERSION= KCFLAGS=-D__ANDROID_COMMON_KERNEL__ "$@" -C $R/$m M=${EXTM:-../$m} KERNEL_SRC=$K OUT_DIR=$KO O=$KO \
    > $OUT/logs/$(echo $m | tr / _)$SFX.log 2>&1
  local rc=$?; [ $rc -eq 0 ] || FAIL=1
  log "$m$SFX: rc $rc"
}
# MediaTek's device modules; Huaqin's, against their symbols; then MediaTek's other modules. The device modules use
# nothing of Huaqin's at link time: the two audio drivers that call into Huaqin's amplifier drivers look them up at
# run time through hq_kallsyms, as stock's do.
SFX= ext $DM KBUILD_EXTRA_SYMBOLS=$R/verify/stock.symvers
SFX= ext $HQ KBUILD_EXTRA_SYMBOLS=$R/verify/stock.symvers
for m in connectivity/common connectivity/wlan/adaptor/build/connac1x connectivity/wlan/core/gen4m/build/connac1x/6833 \
    connectivity/bt/mt66xx/wmt connectivity/gps/gps_stp connectivity/fmradio gpu fpsgo_cus met_drv_v3 \
    met_drv_v3/met_api sched_cus; do
  case $m in
  # the Wi-Fi driver keeps its build time as a string: stock's
  connectivity/wlan/core/gen4m/*) SFX= ext $VM/$m DRIVER_BUILD_DATE=20260811140018 ;;
  *) SFX= ext $VM/$m ;;
  esac
done
# Xiaomi's Millet. Stock's modules were built against another kernel tree, 6.6.30 (their release string says so);
# the __UNIQUE_ID numbers in them follow that tree's headers, so they are built against the public 6.6.30 kernel,
# configured as the one above and prepared for modules. They import only what the GKI kernel exports, with the same symbol
# versions (checked against stock's), so the kernel built above gives the versions.
K630=$R/kernel-6.6.30; KO630=$OUT/KERNEL_OBJ-6.6.30; REL630=6.6.30-android15-8-g41085fa58973-4k
# (the kernel alone: without the device modules' Kconfig, which only the build of the device modules needs)
mk630() { make -j$JOBS ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1 KERNELRELEASE=$REL630 -C $K630 O=$KO630 "$@"; }
rm -rf $KO630; mkdir -p $KO630; cp $K630/arch/arm64/configs/gki_defconfig $KO630/.config; mk630 olddefconfig > $OUT/logs/config-6.6.30.log 2>&1
for c in mgk_64_k66.config mt6833_overlay.config gold.config; do
  (cd $KO630 && $K630/scripts/kconfig/merge_config.sh -m -O $KO630 $KO630/.config $R/$DM/kernel/configs/$c) >> $OUT/logs/config-6.6.30.log 2>&1
  mk630 olddefconfig >> $OUT/logs/config-6.6.30.log 2>&1
done
mk630 modules_prepare >> $OUT/logs/config-6.6.30.log 2>&1; cp $KO/Module.symvers $KO630/
log "kernel 6.6.30: release $(cat $KO630/include/config/kernel.release)"
# (a copy in $OUT, given by its full path: 6.6.30's last step of an external build takes no relative one, and with
# a full path the build writes next to the sources; Millet's sources use no __FILE__, so the path leaves nothing in
# the modules)
XM=$OUT/vendor/xiaomi/kernel_modules/millet; mkdir -p $XM; cp -r $R/vendor/xiaomi/kernel_modules/millet/. $XM/
K=$K630 KO=$KO630 EXTM=$XM SFX= ext vendor/xiaomi/kernel_modules/millet KERNELRELEASE=$REL630

rm -rf $OUT/modules; mkdir -p $OUT/modules
# the external modules, and the kernel's own modules (stock ships a few of these in vendor_dlkm), without their
# debugging information, as installing them does (INSTALL_MOD_STRIP=1)
find $OUT -name '*.ko' -not -path "$OUT/modules/*" | while read k; do
  llvm-strip --strip-debug -o $OUT/modules/$(basename $k) $k; done
log "modules: $(ls $OUT/modules | wc -l); errors: $(cat $OUT/logs/*.log | grep -c ' error:\|ERROR:')"
[ $FAIL -eq 0 ] || { log "FAILED: a directory did not build; see $OUT/logs"; exit 1; }
