# gold's kernel for LineageOS

The kernel of the Redmi Note 13 5G (`gold`) for LineageOS, built with Kleaf as LineageOS's
[lamu](https://github.com/LineageOS/android_kernel_motorola_lamu_manifest) is: MediaTek's `mgk_64_k66` build
makes the vendor modules, the device tree blob and its overlay from the sources stock's are built from, and the
kernel image and the GKI modules of `system_dlkm` are Google's GKI build, the one stock ships.

| Path | What | Source |
| --- | --- | --- |
| `kernel-6.6` | the kernel the vendor modules are built against | Android common kernel `android15-6.6-2026-01_r34`, the source of Google's GKI build 15511674 that stock ships |
| `kernel_device_modules-6.6` | MediaTek's device modules, gold's configuration and Kleaf build | [android_kernel_xiaomi_gold-modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-modules) |
| `vendor/mediatek/kernel_modules` | MediaTek's other modules (connectivity, GPU, …) | [android_kernel_xiaomi_gold-mediatek_modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-mediatek_modules) |
| `vendor/huaqin/kernel_modules` | Huaqin's drivers | [android_kernel_xiaomi_gold-huaqin_modules](https://github.com/Star-caorui/android_kernel_xiaomi_gold-huaqin_modules) |
| `manifest` | this repository: `build_mgk_64_k66.sh`, and Google's GKI builds (`gki.sha256`, `fetch-gki.sh`, `check-kmi.py`) | |
| `build`, `prebuilts`, `external`, … | Kleaf and its tools | as lamu's manifest |

`build_mgk_64_k66.sh` runs the Kleaf build, then downloads the GKI build `GKI_BUILD` names (default 15511674),
checks it against `gki.sha256` and every vendor module against its symbols, and puts it all in
`out/mgk_64_k66/dist`. A newer GKI build of the same KMI generation: `./fetch-gki.sh <build id> /tmp/x` prints its
`gki.sha256` lines.

## In a LineageOS tree

LineageOS's `build_kernel` syncs only the manifests LineageOS hosts, so this one is synced by hand, once, into
the directory it builds in, with a `.repo` of its own as `build_kernel` makes it (without one, `repo init` finds
the Android tree's and initialises that):

```sh
mkdir -p out-kernel/xiaomi_gold/.repo && touch out-kernel/xiaomi_gold/.out-dir
cp -R .repo/repo out-kernel/xiaomi_gold/.repo/repo
cd out-kernel/xiaomi_gold
repo init -u https://github.com/Star-caorui/android_kernel_xiaomi_gold_manifest -b lineage-24.0 --depth=1 --no-use-superproject
repo sync -c --no-tags
cd ../..
export SKIP_KERNEL_SYNC=1
source build/envsetup.sh && breakfast gold
```

`breakfast` runs `build_kernel` (`SKIP_KERNEL_SYNC=1` keeps it from syncing), which builds and puts the dist
directory into `device/xiaomi/gold-kernels`, where the build takes it from. Later syncs: `repo sync -c --no-tags`
in `out-kernel/xiaomi_gold`, then `build_kernel`.

## Compared with stock

The vendor modules this builds, against stock OS3.0.5.0.VNQMIXM's, with the comparison of the
[`OS3.0.5.0.VNQMIXM`](https://github.com/Star-caorui/android_kernel_xiaomi_gold_manifest/tree/OS3.0.5.0.VNQMIXM)
branch: 343 of 353 have every function and every data object of stock's; they differ in the version Kleaf stamps
(`vermagic`, `scmversion`). The 10 others are LineageOS's changes (`ds28e30_verify`, `stick_verify`,
`hq_charger_sysfs`, `leds-mtk`, `mediatek-drm`, `mtk_battery_manager`, `regulator-vibrator`) and the differences
the `OS3.0.5.0.VNQMIXM` branch names (`mtk_charger_framework`, `mtk_pep50`, `wlan_drv_gen4m_6833`). The overlay is
stock's table byte for byte; the blob is stock's but for `initcall_debug=1`, which LineageOS's drops, and
the vibrator's `vmax-min-volt`.
