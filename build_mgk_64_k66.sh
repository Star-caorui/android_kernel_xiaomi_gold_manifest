#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#
# build_mgk_64_k66.sh: gold's kernel, for LineageOS's build_kernel (TARGET_KERNEL_DEVICE := mgk_64_k66), in
# out/mgk_64_k66/dist. MediaTek's Kleaf build makes the vendor modules, the device tree blob and its overlay
# (kernel_device_modules-6.6's build_mgk_64_k66.sh, linked here as build_kernel_device_modules.sh, as
# LineageOS's lamu builds); the kernel the phone runs is Google's
# GKI build, stock's, so its image and its system_dlkm modules (system_dlkm.modules.load lists them) take the place
# of Kleaf's builds of them, after the downloads match gki.sha256 and every vendor module is checked against its
# symbols.
#
#   GKI_BUILD   the GKI build (default: 15511674, stock's; gki.sha256 lists the others)
set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd); M=$ROOT/manifest
GKI_BUILD=${GKI_BUILD:-15511674}
DIST=$ROOT/out/mgk_64_k66/dist

"$ROOT/build_kernel_device_modules.sh"

G=$ROOT/out/gki/$GKI_BUILD
[ -f "$G/kernel" ] || "$M/fetch-gki.sh" "$GKI_BUILD" "$ROOT/out/gki"
rm -f "$DIST"/Image.*
cp "$G/kernel" "$DIST/Image.gz"
# the GKI modules of system_dlkm, flat as the rest, in place of Kleaf's builds of them, and their load list
cp "$G"/system_dlkm/lib/modules/*.ko "$DIST/"
cp "$G/system_dlkm/lib/modules/modules.load" "$DIST/system_dlkm.modules.load"
python3 "$M/check-kmi.py" "$G" "$DIST"
echo "gold's kernel in $DIST, with GKI build $GKI_BUILD"
