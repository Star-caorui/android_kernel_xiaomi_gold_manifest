#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#
# build_mgk_64_k66.sh: gold's kernel, for LineageOS's build_kernel (TARGET_KERNEL_DEVICE := mgk_64_k66), in
# out/mgk_64_k66/dist. The kernel is one of Google's GKI builds, as stock's is: its image and the GKI modules its
# system_dlkm loads go into the package unchanged. MediaTek's Kleaf build (kernel_device_modules-6.6's
# build_mgk_64_k66.sh, linked here as build_kernel_device_modules.sh, as LineageOS's lamu builds) makes the vendor
# modules on that build, as Kleaf takes a prebuilt GKI, so they are linked against its symbols and their CRCs (a
# symbol it does not export stops the build), and the device tree blob and its overlay.
#
# The GKI build is GKI_BUILD below: gki.sha256 has the checksums of its files, and kernel-6.6 is synced at its
# source (default.xml); change the three together.
#
# boot.img is the GKI build's certified boot image with the gzip kernel, as it is: stock's boot.img is its GKI
# build's, with only Xiaomi's AVB footer on top, and the Android build puts gold's footer on this one
# (BOARD_PREBUILT_BOOTIMAGE). It goes in once its kernel is the build's Image.gz and its GKI certificate verifies
# with Google's key.
#
# Kleaf takes the prebuilt with Bzlmod and prebuilt-gki/'s changes to MediaTek's mgk.bzl and gold's build
# scripts, which this applies for the build and takes back after, so the synced projects stay as repo made them.
set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd); M=$ROOT/manifest
GKI_BUILD=16867777
DIST=$ROOT/out/mgk_64_k66/dist
G=$ROOT/out/gki/$GKI_BUILD
P=$M/prebuilt-gki
KLEAF_MODULE=build/kernel/kleaf/bzlmod/bazel.MODULE.bazel

# prebuilt-gki/'s changes: in place (on), or not (off), whichever state an earlier build left
prebuilt() {
    local d
    for d in build/bazel_mgk_rules gold; do
        if git -C "$ROOT/$d" apply -R --check "$P/$(basename $d).patch" 2> /dev/null; then
            [ "$1" = on ] || git -C "$ROOT/$d" apply -R "$P/$(basename $d).patch"
        else
            [ "$1" = off ] || git -C "$ROOT/$d" apply "$P/$(basename $d).patch"
        fi
    done
    rm -f "$ROOT/MODULE.bazel"
    if [ "$1" = on ]; then
        { cat "$ROOT/$KLEAF_MODULE"; sed "s/@GKI_BUILD@/$GKI_BUILD/" "$P/MODULE.bazel.in"; } > "$ROOT/MODULE.bazel"
    else
        ln -s "$KLEAF_MODULE" "$ROOT/MODULE.bazel"  # as the manifest's linkfile has it
    fi
}

[ -f "$G/kleaf/ci_target_mapping.json" ] || "$M/fetch-gki.sh" "$GKI_BUILD" "$ROOT/out/gki"

# The certified boot image, from the build's signed/boot-img.tar.gz (in gki.sha256): a v4 header, the kernel,
# and Google's GKI certificate, one vbmeta blob for the header and kernel ("boot") and one for the kernel
# ("generic_kernel"); then an AVB footer with no signature. avbtool checks the blobs' signatures and hashes,
# and the key has to be Google's: the build's unsigned boot-gz.img has the same blobs, signed with AOSP's
# test key.
GKI_KEY_SHA1=b42c87bedcf600d7bebe3dbade2444e9724c3159
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
tar -xzf "$G/kleaf/signed/boot-img.tar.gz" -C "$work" ./boot-gz.img
python3 -I - "$work/boot-gz.img" "$G/kernel" "$ROOT/prebuilts/kernel-build-tools/linux-x86/bin/avbtool" \
    "$GKI_KEY_SHA1" <<'EOF'
import os, re, struct, subprocess, sys, tempfile

image, kernel, avbtool, key = sys.argv[1:]
img = open(image, "rb").read()
k = open(kernel, "rb").read()

def fail(why):
    sys.exit("the GKI build's certified boot-gz.img: " + why)

kernel_size, ramdisk_size = struct.unpack("<II", img[8:16])
if img[:8] != b"ANDROID!" or struct.unpack("<I", img[40:44])[0] != 4 or ramdisk_size:
    fail("not a v4 boot image of the kernel alone")
page = 4096
if img[page:page + kernel_size] != k:
    fail("its kernel is not the build's Image.gz")
if img[-64:-60] != b"AVBf":
    fail("no AVB footer")
end = struct.unpack(">Q", img[-52:-44])[0]  # the footer's original image size
at = page + -(-kernel_size // page) * page

with tempfile.TemporaryDirectory() as tmp:
    # avbtool checks a hash descriptor against <partition>.img next to the blob
    open(os.path.join(tmp, "boot.img"), "wb").write(img[:at])
    open(os.path.join(tmp, "generic_kernel.img"), "wb").write(k)
    names = []
    while img[at:at + 4] == b"AVB0":
        auth, aux = struct.unpack(">QQ", img[at + 12:at + 28])
        blob = os.path.join(tmp, "certificate%d.img" % len(names))
        open(blob, "wb").write(img[at:at + 256 + auth + aux])
        at += 256 + auth + aux
        if subprocess.run([avbtool, "verify_image", "--image", blob], stdout=subprocess.DEVNULL).returncode:
            fail("its certificate does not verify")
        info = subprocess.run([avbtool, "info_image", "--image", blob], check=True, capture_output=True,
                              text=True).stdout
        if re.search(r"Public key \(sha1\): *(\S+)", info).group(1) != key:
            fail("its certificate is not signed with Google's GKI key")
        names += re.findall(r"Partition Name: *(\S+)", info)
if sorted(names) != ["boot", "generic_kernel"] or at > end or img[at:end].strip(b"\0"):
    fail("its certificate is not the two blobs for boot and generic_kernel")
print("certified boot image: kernel is Image.gz, GKI certificate signed with %s" % key)
EOF

trap 'rm -rf "$work"; prebuilt off' EXIT
prebuilt on
"$ROOT/build_kernel_device_modules.sh"

rm -f "$DIST"/Image.*
cp "$G/kernel" "$DIST/Image.gz"
cp "$work/boot-gz.img" "$DIST/boot.img"
# the GKI modules of system_dlkm, flat as the rest, and their load list
cp "$G"/system_dlkm/lib/modules/*.ko "$DIST/"
cp "$G/system_dlkm/lib/modules/modules.load" "$DIST/system_dlkm.modules.load"
echo "gold's kernel in $DIST, with GKI build $GKI_BUILD"
