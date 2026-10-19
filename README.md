# gold's kernel modules, OS3.0.5.0.VNQMIXM

The sources of the vendor kernel modules of the Redmi Note 13 5G (`gold`) firmware OS3.0.5.0.VNQMIXM, and the
proof that they build into stock's modules. [`default.xml`](default.xml) syncs every part at a fixed commit;
`build.sh` builds the modules; `stock.sh` takes stock's out of Xiaomi's package; `compare.sh` compares the two and
writes [`results.md`](results.md).
`build.sh` also builds the device tree blob of `vendor_boot` from `mt6833.dts` and the overlay of `dtbo` from
`gold.dts`; `compare.sh` checks them against stock's.

## What you need

A Linux x86-64 host with `repo`, `make`, `bc`, `flex`, `bison`, libelf and OpenSSL headers, Python 3, `lz4`,
`cpio` and `fsck.erofs` (erofs-utils), and Xiaomi's full OTA of the firmware for the global model:

```
gold_global-ota_full-OS3.0.5.0.VNQMIXM-user-15.0-df9ff3aa93.zip
SHA-256 35c9f1d98b28538ac10c319ad4cba993cd5a632960d9111162e3efa494dae5c9
https://cdnorg.d.miui.com/OS3.0.5.0.VNQMIXM/gold_global-ota_full-OS3.0.5.0.VNQMIXM-user-15.0-df9ff3aa93.zip
```

[`default.xml`](default.xml) syncs the rest, each at a fixed commit:

| Path | What | Source |
| --- | --- | --- |
| `kernel-6.6` | the kernel | Android common kernel `android15-6.6-2026-01_r34` ([e56cf6b09cca](https://android.googlesource.com/kernel/common/+/e56cf6b09cca)), the GKI kernel on the phone |
| `kernel_device_modules-6.6` | MediaTek's device modules | [android_kernel_xiaomi_gold-modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-modules) |
| `vendor/mediatek/kernel_modules` | MediaTek's other modules (connectivity, GPU, …) | [android_kernel_xiaomi_gold-mediatek_modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-mediatek_modules) |
| `vendor/huaqin/kernel_modules` | Huaqin's drivers | [android_kernel_xiaomi_gold-huaqin_modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-huaqin_modules) |
| `vendor/xiaomi/kernel_modules` | Xiaomi's Millet | [android_kernel_xiaomi_gold-xiaomi_modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-xiaomi_modules) |
| `kernel-6.6.30` | the kernel the Millet modules are built against | Android common kernel `android15-6.6-2024-07_r1` ([ef43fde2fd93](https://android.googlesource.com/kernel/common/+/ef43fde2fd93)): stock's were built against another 6.6.30 tree (`g41085fa58973`, not published), whose headers number their `__UNIQUE_ID` symbols |
| `verify` | this repository | |
| `prebuilts/clang/host/linux-x86` | the compiler | `clang-r510928`, which stock's modules name, from `main-kernel-build-2024` |
| `prebuilts/kernel-build-tools` | build tools (`pahole`, …) | `kernel/prebuilts/build-tools`, `main-kernel-build-2024` |
| `prebuilts/extract-tools`, `system/tools/mkbootimg`, `external/avb` | what `stock.sh` unpacks the package with (`ota_extractor`, `unpack_bootimg.py`, `avbtool.py`) | LineageOS's `android_prebuilts_extract-tools`, AOSP `android-16.0.0_r4` |

The two MediaTek repositories start from MiCode's published commits ([MTK_kernel_device_modules](https://github.com/MiCode/MTK_kernel_device_modules)
and [MTK_kernel_modules](https://github.com/MiCode/MTK_kernel_modules), branch `spark-w-oss`); gold's changes are
the commits after them.

```sh
repo init -u https://github.com/Star-caorui/android_kernel_xiaomi_gold_manifest -b OS3.0.5.0.VNQMIXM
repo sync -c
verify/build.sh
verify/stock.sh gold_global-ota_full-OS3.0.5.0.VNQMIXM-user-15.0-df9ff3aa93.zip
verify/compare.sh stock
```

`build.sh` and `compare.sh` use the synced compiler and tools; `CLANG` and `KBT` point them elsewhere.

`stock.sh` checks the package's SHA-256 and takes stock's files out of it into `stock/`: the kernel, the device tree
blob and the overlay, the modules of the vendor ramdisk, `vendor_dlkm` and `system_dlkm`, and their load lists. No
stock file is kept in git; every comparison starts from Xiaomi's package.

## How it builds

`build.sh` builds the kernel from `kernel-6.6` with `gki_defconfig` and the device modules' fragments
(`mgk_64_k66.config`, `mt6833_overlay.config`, `gold.config`), for its symbols and as the base of the modules' BTF; it
takes a while once. Then, with stock's compiler and stock's release string (`6.6.118-android15-8-g4d05d8779bfd-4k`):

- MediaTek's device modules, then Huaqin's drivers against their symbols, then MediaTek's other modules, each
  directory given from the kernel's (`kernel-6.6/../<directory>`), so that `__FILE__` reads `../<directory>/...` as in
  stock's modules. `stock.symvers` gives the device modules' and Huaqin's builds the CRCs of 14 exports of stock's
  modules. The external modules are built with `__ANDROID_COMMON_KERNEL__`, as the common kernel's build defines
  it, without BTF or scmversion; the kernel's own modules get stock's scmversion. The Wi-Fi driver gets stock's build
  time (`DRIVER_BUILD_DATE`), which it keeps as a string.
- Xiaomi's Millet, against `kernel-6.6.30` prepared for modules with the GKI kernel's `Module.symvers`: stock's were
  built against an unpublished 6.6.30 tree, whose headers number their `__UNIQUE_ID` symbols, and they import only
  what the GKI kernel exports. 6.6.30's external build takes no relative directory, so the directory is built as a
  copy in the output directory; its sources use no `__FILE__`.
- The device tree blob of `vendor_boot` (`mt6833.dts`) and the overlay of `dtbo` (`gold.dts`): each built as the
  kernel's `cmd_dtc` builds a dtb, with the kernel's `dtc` and the include paths of the device modules' dts Makefile,
  and packed in an Android DT table with `mkdtboimg`, as stock's are. Stock's `dtbo` also carries MediaTek's image
  signature after the table, which the bootloader of an unlocked phone does not check.

The modules go to `out/modules/` without their debugging information, as installing them does, the blob to
`out/dtb/gold.dtb` and the overlay to `out/dtb/dtbo.img`.

## How it compares

`fcmp.py` compares each function of each module with the function of the same name in stock's module, instruction
by instruction, after `llvm-objdump`:

- addresses and branch targets are written as the symbol they point to (a branch inside the function as forward or
  backward); relocations as their target symbol, or as the string they point to (its first 400 characters);
- compiler suffixes on names (`.llvm.*`, `.cfi`, `.constprop.*`, `.isra.*`, `.part.*`, `.cold`) are dropped;
- an immediate loaded into an argument register within nine instructions before a call to a print function
  (`_printk`, `dev_*`, `snprintf`, …) is not compared. These are mostly line numbers (`__LINE__`), which change
  with any edit above them; this can also hide another constant printed by the log;
- constant pools and kCFI hashes are not compared; line numbers in `file.c:NNN` strings are not compared.

`dcmp.py` compares each data object of each module with stock's of the same name: its size, and its bytes with
relocations resolved to symbol names. It leaves out objects the build makes rather than the source (`__func__`,
symbol tables of exports and their CRCs, `__UNIQUE_ID`, tracepoint and initcall entries, …; the list is at its top).

`paths.py` reads the source paths the modules name. Stock's build passed each source to the compiler by its path
relative to the kernel's directory, so a file that uses `__FILE__` (in `WARN()`, `BUG()`, assertions, logs) leaves
`../<directory>/<file>` in the module. Each of our modules must name the same paths as stock's, which shows it was
built from the same places, and no absolute path; each file stock's name is looked up in the synced tree. A module
whose sources use no `__FILE__` names none, and where its files were cannot be told.

`bytes.py` compares the whole files (below). A module is **Byte-identical** when only the build ID differs,
**Byte-identical but stock's kernel** when the rest of what differs is decided by stock's unpublished kernel (the
BTF, or line numbers from its headers; see below),
**Code and data identical** when every function and every data object matches but some other bytes do not (a
symbol table, `.modinfo`, a CRC), **Code identical** when every function matches but some data objects do not, and
**Differs** otherwise.

`report.py` writes these levels into [`results.md`](results.md), with the notes `notes.tsv` gives some modules.

## What cannot match

`bytes.py` compares every module byte by byte. Stock's modules carry no signature. Three things cannot be stock's:

| What | Why |
| --- | --- |
| `.note.gnu.build-id` (20 bytes, every module) | the linker hashes the whole module before its debugging information is stripped, and that information names the directories of the machine that built it; nothing in stock's modules tells what they were |
| `.BTF` of the kernel's own modules (`cfg80211.ko`, …) | written against the BTF of the kernel they were built with, Xiaomi's own tree `4d05d8779bfd` (not published); it is not the GKI kernel on the phone (checked against its `/sys/kernel/btf/vmlinux`) |
| Two line numbers from `include/ufs/ufshcd.h` in `ufs-mediatek-mod.ko` and `rpmb-mtk.ko` (`__bug_table`) | the same tree's `ufshcd.h` has three more lines before `ufshcd_set_variant()` than the GKI kernel's (stock's `BUG_ON()`s are at 1349 and 1359, the GKI kernel's at 1346 and 1356); the kernel is not changed for it |

Where stock's sources had lines that leave nothing in the modules (comments, code that is not built) and the files
they were in are not published, blank lines keep the line numbers stock's modules record; the commits that add
them say so.

The build gives the modules stock's release string (`6.6.118-android15-8-g4d05d8779bfd-4k`, in `vermagic`) and the
kernel's own modules stock's `scmversion`; the kernel itself is built from the public `e56cf6b09cca`.
