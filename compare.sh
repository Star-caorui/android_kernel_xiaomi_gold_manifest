#!/bin/bash
# compare.sh <stock modules> [out]: compare the modules build.sh made (<out>/modules, default out/modules) with
# stock's byte by byte, function by function and data object by data object, check that both name the same
# source paths, compare the device tree blob and the overlay build.sh made (<out>/dtb/gold.dtb, <out>/dtb/dtbo.img)
# with stock's dtb/gold.dtb and dtbo.img, and write verify/results.md.
#
# <stock modules> is a directory with stock's vendor_ramdisk/ and vendor_dlkm/ (or the .ko files directly), as
# stock.sh takes them out of Xiaomi's package (stock/ in a tree synced from default.xml). CLANG as for build.sh.
set -eu
V=$(cd "$(dirname "$0")" && pwd); ST=$1; OUT=${2:-$V/../out}; C=$OUT/compare
# the compiler's llvm-objdump: CLANG as build.sh takes it (default: clang-r510928, as default.xml syncs it)
CLANG=${CLANG:-$V/../prebuilts/clang/host/linux-x86/clang-r510928}; export OBJDUMP=${OBJDUMP:-$CLANG/bin/llvm-objdump}
[ -x "$OBJDUMP" ] || { echo "no llvm-objdump at $OBJDUMP" >&2; exit 1; }
mkdir -p $C/data
python3 $V/fcmp.py $ST $OUT/modules $C
python3 $V/dcmp.py $ST $OUT/modules $C
python3 $V/paths.py $ST $OUT/modules $V/.. $C
python3 $V/bytes.py $ST $OUT/modules $C
DTB_STOCK=$ST/dtb/gold.dtb DTB_OURS=$OUT/dtb/gold.dtb DTBO_STOCK=$ST/dtbo.img DTBO_OURS=$OUT/dtb/dtbo.img python3 $V/report.py $ST $OUT/modules $C > $V/results.md
echo "$V/results.md"
