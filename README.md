# gold's kernel for LineageOS

Builds the kernel of the Redmi Note 13 5G (`gold`) for LineageOS 24.0. The kernel itself is Google's GKI build,
unchanged, as on stock; this builds the vendor modules on it, and the device tree blob and overlay.

## Build

```sh
repo init -u https://github.com/Star-caorui/android_kernel_xiaomi_gold_manifest -b lineage-24.0 --depth=1 --no-use-superproject
repo sync -c --no-tags
./build_mgk_64_k66.sh
```

The result is in `out/mgk_64_k66/dist`, flat:

| File | What |
| --- | --- |
| `Image.gz` | the GKI kernel, Google's |
| `boot.img` | its certified boot image (kernel + Google's GKI certificate), Google's, for `BOARD_PREBUILT_BOOTIMAGE` |
| `system_dlkm.modules.load` and its `.ko` | the GKI modules `system_dlkm` loads, Google's, signed |
| the other `.ko` | the vendor modules, built here |
| `mt6833.dtb`, `dtbo.img` | the device tree blob and overlay, built here |
| `kernel-uapi-headers.tar.gz` | the uapi headers, Google's and MediaTek's |

Google's files are downloaded from ci.android.com and checked against `gki.sha256`. The build stops if a download
does not match, or if a module needs a symbol the GKI build does not export. It takes about 15 minutes on 4 CPUs
from scratch.

## The GKI build

| | |
| --- | --- |
| GKI build (`GKI_BUILD` in `build_mgk_64_k66.sh`) | 16867777 |
| `kernel-6.6` (`default.xml`) | `android15-6.6-2026-10_r3`, its source |

To move to another build: `./fetch-gki.sh <build id> /tmp/x` prints its `gki.sha256` lines; add them, drop the
oldest build's (it keeps the two newest), and change `GKI_BUILD` and the `kernel-6.6` tag with them.

## In a LineageOS tree

```sh
mkdir -p out-kernel/xiaomi_gold/.repo && touch out-kernel/xiaomi_gold/.out-dir
cp -R .repo/repo out-kernel/xiaomi_gold/.repo/repo
(cd out-kernel/xiaomi_gold && repo init -u https://github.com/Star-caorui/android_kernel_xiaomi_gold_manifest -b lineage-24.0 --depth=1 --no-use-superproject && repo sync -c --no-tags)
export SKIP_KERNEL_SYNC=1
source build/envsetup.sh && breakfast gold
```

`breakfast` runs `build_kernel`, which puts the dist into the device tree's `TARGET_KERNEL_DIR`,
`device/xiaomi/gold-kernel`. The `.repo` of its own keeps `repo init` from taking the Android tree's.

## The GKI kernel from source

To build the kernel itself, with changes of one's own, in a synced tree:

```sh
KERNEL_VERSION=kernel-6.6 tools/bazel run --noenable_bzlmod --config=stamp //kernel-6.6:kernel_aarch64_dist -- --destdir=out/gki-src
```

Unchanged, it exports the same symbols as Google's build, so the vendor modules load on it; changes that keep the
KMI keep that.

## This repository

| File | What |
| --- | --- |
| `default.xml` | the sources: Kleaf and its tools, `kernel-6.6`, and gold's module sources ([android_kernel_xiaomi_gold](https://github.com/Star-caorui/android_kernel_xiaomi_gold)) |
| `build_mgk_64_k66.sh` | the build, and which GKI build it takes |
| `gki.sha256`, `fetch-gki.sh` | the GKI build's files' checksums, and their download |
| `prebuilt-gki/` | what the build changes in MediaTek's Kleaf rules and gold's build scripts so they take the GKI build instead of compiling a kernel; applied for the build and taken back after |

## Compared with stock

The vendor modules have every function and data object of stock OS3.0.5.0.VNQMIXM's but for LineageOS's changes
and a few known differences; see the
[comparison](https://github.com/Star-caorui/android_kernel_xiaomi_gold/tree/OS3.0.5.0.VNQMIXM/verify).
