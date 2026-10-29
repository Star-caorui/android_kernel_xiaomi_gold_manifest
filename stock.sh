#!/bin/bash
# stock.sh <package> [out]: take stock's kernel files out of Xiaomi's full OTA of OS3.0.5.0.VNQMIXM for the global
# model, after checking the package, into <out> (default: stock/ in the synced tree), as compare.sh reads them:
#
#   kernel                        the kernel image in the boot partition
#   dtb/gold.dtb                  the device tree blob in the vendor_boot partition
#   dtbo.img                      the dtbo partition, without the padding and the AVB footer
#   vendor_ramdisk/*.ko           lib/modules/ in the vendor ramdisk of vendor_boot
#   modules.load.vendor_ramdisk   lib/modules/modules.load in the same ramdisk
#   modules.load.recovery         lib/modules/modules.load.recovery in the same ramdisk
#   vendor_dlkm/*.ko              lib/modules/ in the vendor_dlkm partition
#   modules.load.vendor           lib/modules/modules.load in the vendor_dlkm partition
#   system_dlkm/lib/modules/      the same path in the system_dlkm partition
#
# The package is gold_global-ota_full-OS3.0.5.0.VNQMIXM-user-15.0-df9ff3aa93.zip, on Xiaomi's servers at
# https://cdnorg.d.miui.com/OS3.0.5.0.VNQMIXM/ and others. Needs python3, lz4, cpio and fsck.erofs (erofs-utils) on
# the host; ota_extractor, unpack_bootimg.py and avbtool.py come from the tree default.xml syncs.
set -eu
R=$(cd "$(dirname "$0")/.." && pwd)
ZIP=$(readlink -f "$1"); OUT=${2:-$R/stock}
[ ! -e "$OUT" ] || [ -z "$(ls -A "$OUT")" ] || { echo "$OUT is not empty" >&2; exit 1; }
SHA256=35c9f1d98b28538ac10c319ad4cba993cd5a632960d9111162e3efa494dae5c9

echo "checking $ZIP"
[ "$(sha256sum "$ZIP" | cut -d' ' -f1)" = $SHA256 ] ||
  { echo "not gold_global-ota_full-OS3.0.5.0.VNQMIXM-user-15.0-df9ff3aa93.zip (SHA-256 $SHA256)" >&2; exit 1; }

W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
# payload.bin is stored in the package uncompressed; ota_extractor reads it there, from its offset
OFF=$(python3 - "$ZIP" <<'PY'
import struct, sys, zipfile
i = zipfile.ZipFile(sys.argv[1]).getinfo('payload.bin')
assert i.compress_type == zipfile.ZIP_STORED
with open(sys.argv[1], 'rb') as f:
    f.seek(i.header_offset)
    name_len, extra_len = struct.unpack('<HH', f.read(30)[26:30])
print(i.header_offset + 30 + name_len + extra_len)
PY
)
mkdir -p "$W/img" "$W/ramdisk"
"$R/prebuilts/extract-tools/linux-x86/bin/ota_extractor" --payload "$ZIP" --payload_offset "$OFF" \
  --output_dir "$W/img" --partitions boot,vendor_boot,dtbo,vendor_dlkm,system_dlkm
python3 "$R/system/tools/mkbootimg/unpack_bootimg.py" --boot_img "$W/img/boot.img" --out "$W/boot" > /dev/null
python3 "$R/system/tools/mkbootimg/unpack_bootimg.py" --boot_img "$W/img/vendor_boot.img" --out "$W/vendor_boot" > /dev/null
for f in "$W"/vendor_boot/vendor_ramdisk0*; do
  lz4 -dc "$f" | (cd "$W/ramdisk" && cpio -idmu --quiet)
done
fsck.erofs --extract="$W/vendor_dlkm" "$W/img/vendor_dlkm.img" > /dev/null
fsck.erofs --extract="$W/system_dlkm" "$W/img/system_dlkm.img" > /dev/null
python3 "$R/external/avb/avbtool.py" erase_footer --image "$W/img/dtbo.img"

mkdir -p "$OUT/dtb" "$OUT/vendor_ramdisk" "$OUT/vendor_dlkm" "$OUT/system_dlkm/lib"
cp "$W/boot/kernel" "$OUT/kernel"
cp "$W/vendor_boot/dtb" "$OUT/dtb/gold.dtb"
cp "$W/img/dtbo.img" "$OUT/dtbo.img"
cp "$W"/ramdisk/lib/modules/*.ko "$OUT/vendor_ramdisk/"
cp "$W/ramdisk/lib/modules/modules.load" "$OUT/modules.load.vendor_ramdisk"
cp "$W/ramdisk/lib/modules/modules.load.recovery" "$OUT/modules.load.recovery"
cp "$W"/vendor_dlkm/lib/modules/*.ko "$OUT/vendor_dlkm/"
cp "$W/vendor_dlkm/lib/modules/modules.load" "$OUT/modules.load.vendor"
cp -r "$W/system_dlkm/lib/modules" "$OUT/system_dlkm/lib/"
echo "$OUT"
