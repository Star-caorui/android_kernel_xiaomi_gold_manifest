# Results

Made by `verify/compare.sh` from the sources `default.xml` syncs. What the columns mean is in `verify/README.md`.

| | Modules |
| --- | --- |
| Stock vendor modules | 360 |
| Built and compared (the synced sources, and the kernel's own modules) | 360 |
| Byte-identical, but for the build ID | 332 |
| Byte-identical, but for the build ID and what stock's unpublished kernel decides (the BTF of the kernel's own modules, line numbers from its headers) | 15 |
| Code and data identical: every function and every data object, but not every byte | 10 |
| Code identical: every function, but some data objects differ | 0 |
| Differs | 3 |
| Stock modules without published source | 0 |

## Device tree blob

| | |
| --- | --- |
| `dtb/gold.dtb` of `vendor_boot` (mt6833.dts in an Android DT table), against stock's | Byte-identical |
| `dtbo.img` (gold.dts in an Android DT table), against stock's | Byte-identical, but for MediaTek's signature after stock's table |

## Source paths

Where each source file was built from, as far as the modules name the path (`verify/paths.py`): stock's
modules against ours, and the files stock's name against the synced tree. The rest of the layout follows
MiCode's sources and cannot be checked this way.

| | |
| --- | --- |
| Stock modules that name source paths | 123 |
| Stock modules that name none | 237 |
| Of the ones we build, naming the same paths as stock's | 123 of 123 |
| Paths stock's modules name, found at the same place in the synced tree | 411 of 411 |
| Absolute paths in our modules | 0 |

## Compared modules

| Module | Status | Functions same | Differ | Only stock | Only ours | Data objects differing | Bytes differing in | Note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `8250_mtk.ko` | Byte-identical | 70 | 0 | 0 | 0 | 0 |  |  |
| `CPU_DVFS.ko` | Byte-identical | 175 | 0 | 0 | 0 | 0 |  |  |
| `Upower.ko` | Byte-identical | 22 | 0 | 0 | 0 | 0 |  |  |
| `adapter_class.ko` | Byte-identical | 37 | 0 | 0 | 0 | 0 |  |  |
| `aee_aed.ko` | Byte-identical | 118 | 0 | 0 | 0 | 0 |  |  |
| `aee_hangdet.ko` | Byte-identical | 40 | 0 | 0 | 0 | 0 |  |  |
| `aee_rs.ko` | Byte-identical | 9 | 0 | 0 | 0 | 0 |  |  |
| `archcounter_timesync.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `auth_battery.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `battery_auth_class.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `binder_prio.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `blocktag.ko` | Byte-identical | 118 | 0 | 0 | 0 | 0 |  |  |
| `bootprof.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `bt_drv_connac1x.ko` | Byte-identical | 52 | 0 | 0 | 0 | 0 |  |  |
| `btif_drv.ko` | Byte-identical | 153 | 0 | 0 | 0 | 0 |  |  |
| `c2k_usb.ko` | Byte-identical | 42 | 0 | 0 | 0 | 0 |  |  |
| `c2k_usb_f_via_atc.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `c2k_usb_f_via_ets.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `c2k_usb_f_via_modem.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `cache-parity.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `cam_qos.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `camera_dip_isp6s.ko` | Byte-identical | 42 | 0 | 0 | 0 | 0 |  |  |
| `camera_dpe_isp60.ko` | Byte-identical | 90 | 0 | 0 | 0 | 0 |  |  |
| `camera_eeprom.ko` | Byte-identical | 19 | 0 | 0 | 0 | 0 |  |  |
| `camera_fdvt_isp51.ko` | Byte-identical | 41 | 0 | 0 | 0 | 0 |  |  |
| `camera_isp.ko` | Byte-identical | 63 | 0 | 0 | 0 | 0 |  |  |
| `camera_mem.ko` | Byte-identical | 19 | 0 | 0 | 0 | 0 |  |  |
| `camera_mfb_isp6s.ko` | Byte-identical | 72 | 0 | 0 | 0 | 0 |  |  |
| `camera_rsc_isp6s.ko` | Byte-identical | 47 | 0 | 0 | 0 | 0 |  |  |
| `ccci_auxadc.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `ccci_ccif.ko` | Byte-identical | 44 | 0 | 0 | 0 | 0 |  |  |
| `ccci_dpmaif.ko` | Byte-identical | 214 | 0 | 0 | 0 | 0 |  |  |
| `ccci_fsm_scp.ko` | Byte-identical | 17 | 0 | 0 | 0 | 0 |  |  |
| `ccci_md_all.ko` | Byte-identical | 392 | 0 | 0 | 0 | 0 |  |  |
| `ccci_util_lib.ko` | Byte-identical | 128 | 0 | 0 | 0 | 0 |  |  |
| `ccmni.ko` | Byte-identical | 33 | 0 | 0 | 0 | 0 |  |  |
| `ccu_isp6s.ko` | Byte-identical | 82 | 0 | 0 | 0 | 0 |  |  |
| `charger_class.ko` | Byte-identical | 103 | 0 | 0 | 0 | 0 |  |  |
| `clk-chk-mt6833.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `clk-common.ko` | Byte-identical | 199 | 0 | 0 | 0 | 0 |  |  |
| `clk-dbg-mt6833.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `clk-disable-unused.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-fmeter-mt6833.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-audiosys.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-bus.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-cam.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-i2c.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-img.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-mfgcfg.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-mmsys.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833-vcodec.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `clk-mt6833.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `clkbuf.ko` | Byte-identical | 89 | 0 | 0 | 0 | 0 |  |  |
| `cmdq-bdg-mailbox.ko` | Byte-identical | 32 | 0 | 0 | 0 | 0 |  |  |
| `cmdq-bdg-test.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `cmdq-platform-mt6833.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `cmdq-sec-drv.ko` | Byte-identical | 63 | 0 | 0 | 0 | 0 |  |  |
| `cmdq-test.ko` | Byte-identical | 29 | 0 | 0 | 0 | 0 |  |  |
| `cmdq_helper_inf.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `conn_md_drv.ko` | Byte-identical | 31 | 0 | 0 | 0 | 0 |  |  |
| `connadp.ko` | Byte-identical | 76 | 0 | 0 | 0 | 0 |  |  |
| `cpufreq_sugov_ext.ko` | Byte-identical | 331 | 0 | 0 | 0 | 0 |  |  |
| `cpumaxfreq.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `cqhci.ko` | Byte-identical | 23 | 0 | 0 | 0 | 0 |  |  |
| `device-apc-common.ko` | Byte-identical | 26 | 0 | 0 | 0 | 0 |  |  |
| `device-apc-mt6833.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `devmpu.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `ds28e30_verify.ko` | Byte-identical | 158 | 0 | 0 | 0 | 0 |  |  |
| `eas_ext.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `emi-dummy.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `emi-mpu-test.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `emi-mpu.ko` | Byte-identical | 21 | 0 | 0 | 0 | 0 |  |  |
| `emi.ko` | Byte-identical | 20 | 0 | 0 | 0 | 0 |  |  |
| `extcon-mtk-usb.ko` | Byte-identical | 22 | 0 | 0 | 0 | 0 |  |  |
| `extdev_io_class.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `fhctl.ko` | Byte-identical | 32 | 0 | 0 | 0 | 0 |  |  |
| `flashlight.ko` | Byte-identical | 49 | 0 | 0 | 0 | 0 |  |  |
| `fmradio_drv_mt6631_6635.ko` | Byte-identical | 399 | 0 | 0 | 0 | 0 |  |  |
| `focaltech_tp.ko` | Byte-identical | 235 | 0 | 0 | 0 | 0 |  |  |
| `fpc1022_tee.ko` | Byte-identical | 17 | 0 | 0 | 0 | 0 |  |  |
| `fpsgo.ko` | Byte-identical | 33 | 0 | 0 | 0 | 0 |  |  |
| `ged.ko` | Byte-identical | 1064 | 0 | 0 | 0 | 0 |  |  |
| `gf_spi_tee.ko` | Byte-identical | 31 | 0 | 0 | 0 | 0 |  |  |
| `gps_drv_stp.ko` | Byte-identical | 74 | 0 | 0 | 0 | 0 |  |  |
| `gt9886.ko` | Byte-identical | 113 | 0 | 0 | 0 | 0 |  |  |
| `gt9896s.ko` | Byte-identical | 81 | 0 | 0 | 0 | 0 |  |  |
| `gt9916r.ko` | Byte-identical | 185 | 0 | 0 | 0 | 0 |  |  |
| `gz_ipc_mod.ko` | Byte-identical | 43 | 0 | 0 | 0 | 0 |  |  |
| `gz_irq_mod.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `gz_log_mod.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `gz_main_mod.ko` | Byte-identical | 35 | 0 | 0 | 0 | 0 |  |  |
| `gz_trusty_mod.ko` | Byte-identical | 31 | 0 | 0 | 0 | 0 |  |  |
| `gz_tz_system.ko` | Byte-identical | 54 | 0 | 0 | 0 | 0 |  |  |
| `gz_virtio_mod.ko` | Byte-identical | 25 | 0 | 0 | 0 | 0 |  |  |
| `hf_manager.ko` | Byte-identical | 45 | 0 | 0 | 0 | 0 |  |  |
| `hq_charger_sysfs.ko` | Byte-identical | 24 | 0 | 0 | 0 | 0 |  |  |
| `hq_kallsyms.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `hq_notifier.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `hq_notify.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `hqsys_misc.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `hqsys_pcba.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `hqsysfs.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `i2c-mt65xx.ko` | Byte-identical | 28 | 0 | 0 | 0 | 0 |  |  |
| `imgsensor_isp6s.ko` | Byte-identical | 245 | 0 | 0 | 0 | 0 |  |  |
| `iommu_debug.ko` | Byte-identical | 61 | 0 | 0 | 0 | 0 |  |  |
| `iommu_gz.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `iommu_secure.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `iommu_test.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `irq-dbg.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `leds-mt6360.ko` | Byte-identical | 28 | 0 | 0 | 0 | 0 |  |  |
| `leds-mtk-disp.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `leds-mtk-pwm.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `leds-mtk.ko` | Byte-identical | 25 | 0 | 0 | 0 | 0 |  |  |
| `ln8000_charger.ko` | Byte-identical | 38 | 0 | 0 | 0 | 0 |  |  |
| `load_track.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `log_store.ko` | Byte-identical | 20 | 0 | 0 | 0 | 0 |  |  |
| `main2af.ko` | Byte-identical | 77 | 0 | 0 | 0 | 0 |  |  |
| `main3af.ko` | Byte-identical | 26 | 0 | 0 | 0 | 0 |  |  |
| `mainaf.ko` | Byte-identical | 265 | 0 | 0 | 0 | 0 |  |  |
| `mali_mgm_mt6833_r49.ko` | Byte-identical | 57 | 0 | 0 | 0 | 0 |  |  |
| `mali_prot_alloc_mt6833_r49.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `mcupm.ko` | Byte-identical | 39 | 0 | 0 | 0 | 0 |  |  |
| `mddp.ko` | Byte-identical | 133 | 0 | 0 | 0 | 0 |  |  |
| `mdp_drv_mt6833.ko` | Byte-identical | 648 | 0 | 0 | 0 | 0 |  |  |
| `mediatek_eem.ko` | Byte-identical | 59 | 0 | 0 | 0 | 0 |  |  |
| `mediatek_static_power.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `memory-amms.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `met.ko` | Byte-identical | 928 | 0 | 0 | 0 | 0 |  |  |
| `met_backlight_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_emi_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_gpu_adv_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_gpu_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_ipi_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_mcupm_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_scmi_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_sspm_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `met_vcore_api.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `mi_memory.ko` | Byte-identical | 24 | 0 | 0 | 0 | 0 |  |  |
| `miev.ko` | Byte-identical | 20 | 0 | 0 | 0 | 0 |  |  |
| `millet_binder.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `millet_core.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `millet_hs.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `millet_oem_cgroup.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `millet_pkg.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `millet_sig.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `mme.ko` | Byte-identical | 20 | 0 | 0 | 0 | 0 |  |  |
| `mmprofile.ko` | Byte-identical | 40 | 0 | 0 | 0 | 0 |  |  |
| `mmqos-common.ko` | Byte-identical | 167 | 0 | 0 | 0 | 0 |  |  |
| `mmqos-mt6833.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `mmqos_wrapper.ko` | Byte-identical | 15 | 0 | 0 | 0 | 0 |  |  |
| `monitor_hang.ko` | Byte-identical | 35 | 0 | 0 | 0 | 0 |  |  |
| `mrdump.ko` | Byte-identical | 133 | 0 | 0 | 0 | 0 |  |  |
| `mt6315-regulator.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `mt6359p-accdet.ko` | Byte-identical | 51 | 0 | 0 | 0 | 0 |  |  |
| `mt6359p-regulator.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `mt635x-auxadc.ko` | Byte-identical | 29 | 0 | 0 | 0 | 0 |  |  |
| `mt6360-adc.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `mt6360-core.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `mt6360-regulator.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `mt6360_pmu_chg.ko` | Byte-identical | 117 | 0 | 0 | 0 | 0 |  |  |
| `mt6397.ko` | Byte-identical | 20 | 0 | 0 | 0 | 0 |  |  |
| `mt63xx-debug.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `mt6577_auxadc.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `mt6833-mt6359p.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `mt6833_dcm.ko` | Byte-identical | 92 | 0 | 0 | 0 | 0 |  |  |
| `mtk-afe-external.ko` | Byte-identical | 17 | 0 | 0 | 0 | 0 |  |  |
| `mtk-btcvsd.ko` | Byte-identical | 33 | 0 | 0 | 0 | 0 |  |  |
| `mtk-cmdq-drv-ext.ko` | Byte-identical | 331 | 0 | 0 | 0 | 0 |  |  |
| `mtk-composite.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `mtk-cqdma.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `mtk-dvfsrc-devfreq.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `mtk-dvfsrc-helper.ko` | Byte-identical | 96 | 0 | 0 | 0 | 0 |  |  |
| `mtk-dvfsrc-regulator.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `mtk-dvfsrc-start.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `mtk-dvfsrc.ko` | Byte-identical | 89 | 0 | 0 | 0 | 0 |  |  |
| `mtk-emi.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `mtk-icc-core.ko` | Byte-identical | 39 | 0 | 0 | 0 | 0 |  |  |
| `mtk-kpd.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `mtk-lpm-dbg-common-v1-legacy.ko` | Byte-identical | 125 | 0 | 0 | 0 | 0 |  |  |
| `mtk-lpm-dbg-mt6833-legacy.ko` | Byte-identical | 25 | 0 | 0 | 0 | 0 |  |  |
| `mtk-lpm-legacy.ko` | Byte-identical | 93 | 0 | 0 | 0 | 0 |  |  |
| `mtk-lpm-plat-v1-legacy.ko` | Byte-identical | 30 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mbox.ko` | Byte-identical | 49 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmc-dbg.ko` | Byte-identical | 29 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmc-wp.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmc.ko` | Byte-identical | 69 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmdebug-vcp-stub.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmdvfs-debug.ko` | Byte-identical | 24 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmdvfs-ftrace.ko` | Byte-identical | 35 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mmdvfs.ko` | Byte-identical | 26 | 0 | 0 | 0 | 0 |  |  |
| `mtk-mml.ko` | Byte-identical | 638 | 0 | 0 | 0 | 0 |  |  |
| `mtk-pm-domain-disable-unused.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `mtk-pmic-keys.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `mtk-pmic-wrap.ko` | Byte-identical | 46 | 0 | 0 | 0 | 0 |  |  |
| `mtk-pwm.ko` | Byte-identical | 87 | 0 | 0 | 0 | 0 |  |  |
| `mtk-scp-vow.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `mtk-scpsys-bringup.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `mtk-scpsys-mt6833.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `mtk-scpsys.ko` | Byte-identical | 38 | 0 | 0 | 0 | 0 |  |  |
| `mtk-smi-dbg.ko` | Byte-identical | 60 | 0 | 0 | 0 | 0 |  |  |
| `mtk-smi.ko` | Byte-identical | 52 | 0 | 0 | 0 | 0 |  |  |
| `mtk-socinfo.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `mtk-sp-spk-amp.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `mtk-spmi-pmic.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `mtk-uart-apdma.ko` | Byte-identical | 40 | 0 | 0 | 0 | 0 |  |  |
| `mtk-vcodec-common.ko` | Byte-identical | 75 | 0 | 0 | 0 | 0 |  |  |
| `mtk-vcodec-dec-v1.ko` | Byte-identical | 213 | 0 | 0 | 0 | 0 |  |  |
| `mtk-vcodec-enc-v1.ko` | Byte-identical | 194 | 0 | 0 | 0 | 0 |  |  |
| `mtk-vcu.ko` | Byte-identical | 62 | 0 | 0 | 0 | 0 |  |  |
| `mtk-vow.ko` | Byte-identical | 77 | 0 | 0 | 0 | 0 |  |  |
| `mtk_battery_oc_throttling.ko` | Byte-identical | 23 | 0 | 0 | 0 | 0 |  |  |
| `mtk_bp_thl.ko` | Byte-identical | 19 | 0 | 0 | 0 | 0 |  |  |
| `mtk_charger_algorithm_class.ko` | Byte-identical | 23 | 0 | 0 | 0 | 0 |  |  |
| `mtk_cm_mgr.ko` | Byte-identical | 42 | 0 | 0 | 0 | 0 |  |  |
| `mtk_cm_mgr_mt6833.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `mtk_core_ctl.ko` | Byte-identical | 115 | 0 | 0 | 0 | 0 |  |  |
| `mtk_cpu_power_throttling.ko` | Byte-identical | 34 | 0 | 0 | 0 | 0 |  |  |
| `mtk_cpuhp.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `mtk_dcm.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `mtk_disp_notify.ko` | Byte-identical | 9 | 0 | 0 | 0 | 0 |  |  |
| `mtk_disp_sec.ko` | Byte-identical | 36 | 0 | 0 | 0 | 0 |  |  |
| `mtk_dramc.ko` | Byte-identical | 17 | 0 | 0 | 0 | 0 |  |  |
| `mtk_dynamic_loading_throttling.ko` | Byte-identical | 9 | 0 | 0 | 0 | 0 |  |  |
| `mtk_fpsgo.ko` | Byte-identical | 830 | 0 | 0 | 0 | 0 |  |  |
| `mtk_gpu_hal.ko` | Byte-identical | 47 | 0 | 0 | 0 | 0 |  |  |
| `mtk_gpu_qos.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `mtk_gpufreq_mt6833.ko` | Byte-identical | 103 | 0 | 0 | 0 | 0 |  |  |
| `mtk_gpufreq_wrapper_legacy.ko` | Byte-identical | 81 | 0 | 0 | 0 | 0 |  |  |
| `mtk_heap_debug.ko` | Byte-identical | 41 | 0 | 0 | 0 | 0 |  |  |
| `mtk_ioctl_powerhal.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `mtk_ioctl_touch_boost.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `mtk_iommu.ko` | Byte-identical | 55 | 0 | 0 | 0 | 0 |  |  |
| `mtk_iommu_util.ko` | Byte-identical | 3 | 0 | 0 | 0 | 0 |  |  |
| `mtk_irtx_pwm.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `mtk_jpeg.ko` | Byte-identical | 65 | 0 | 0 | 0 | 0 |  |  |
| `mtk_low_battery_throttling.ko` | Byte-identical | 56 | 0 | 0 | 0 | 0 |  |  |
| `mtk_md_power_throttling.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `mtk_mdpm_v1.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `mtk_panel_ext.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `mtk_pbm.ko` | Byte-identical | 31 | 0 | 0 | 0 | 0 |  |  |
| `mtk_pd_adapter.ko` | Byte-identical | 24 | 0 | 0 | 0 | 0 |  |  |
| `mtk_pd_charging.ko` | Byte-identical | 51 | 0 | 0 | 0 | 0 |  |  |
| `mtk_peak_power_budget.ko` | Byte-identical | 92 | 0 | 0 | 0 | 0 |  |  |
| `mtk_pep.ko` | Byte-identical | 40 | 0 | 0 | 0 | 0 |  |  |
| `mtk_pep20.ko` | Byte-identical | 47 | 0 | 0 | 0 | 0 |  |  |
| `mtk_pep40.ko` | Byte-identical | 68 | 0 | 0 | 0 | 0 |  |  |
| `mtk_perf_common.ko` | Byte-identical | 85 | 0 | 0 | 0 | 0 |  |  |
| `mtk_perf_ioctl.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `mtk_picachu.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `mtk_ppm_v3.ko` | Byte-identical | 234 | 0 | 0 | 0 | 0 |  |  |
| `mtk_printk_ctrl.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `mtk_qos.ko` | Byte-identical | 55 | 0 | 0 | 0 | 0 |  |  |
| `mtk_rpmsg_mbox.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `mtk_sec_heap.ko` | Byte-identical | 31 | 0 | 0 | 0 | 0 |  |  |
| `mtk_sync.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `mtk_tinysys_ipi.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `mtk_u_ether.ko` | Byte-identical | 35 | 0 | 0 | 0 | 0 |  |  |
| `mtk_usb_f_rndis.ko` | Byte-identical | 50 | 0 | 0 | 0 | 0 |  |  |
| `mtk_wdt.ko` | Byte-identical | 15 | 0 | 0 | 0 | 0 |  |  |
| `musb_boost.ko` | Byte-identical | 48 | 0 | 0 | 0 | 0 |  |  |
| `musb_hdrc.ko` | Byte-identical | 359 | 0 | 0 | 0 | 0 |  |  |
| `musb_main.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `nanohub.ko` | Byte-identical | 77 | 0 | 0 | 0 | 0 |  |  |
| `nvmem-mt635x-efuse.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `nvmem_mtk-devinfo.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `panel-n17-36-0f-0c-dsc-vdo.ko` | Byte-identical | 27 | 0 | 0 | 0 | 0 |  |  |
| `panel-n17-42-0d-0b-dsc-vdo.ko` | Byte-identical | 27 | 0 | 0 | 0 | 0 |  |  |
| `panel-nt35695b-auo-vdo.ko` | Byte-identical | 15 | 0 | 0 | 0 | 0 |  |  |
| `panel-samsung-s68fc01-vdo-aod.ko` | Byte-identical | 25 | 0 | 0 | 0 | 0 |  |  |
| `panel-tianma-nt36672c-cphy-vdo-90hz-rt4801.ko` | Byte-identical | 16 | 0 | 0 | 0 | 0 |  |  |
| `panel-truly-ft8756-vdo.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `panel-truly-td4330-cmd.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `panel-truly-td4330-vdo.ko` | Byte-identical | 14 | 0 | 0 | 0 | 0 |  |  |
| `pd-chk-mt6833.ko` | Byte-identical | 13 | 0 | 0 | 0 | 0 |  |  |
| `pd_dbg_info.ko` | Byte-identical | 4 | 0 | 0 | 0 | 0 |  |  |
| `phy-mtk-tphy.ko` | Byte-identical | 44 | 0 | 0 | 0 | 0 |  |  |
| `phy-mtk-ufs.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `pinctrl-mt6833.ko` | Byte-identical | 1 | 0 | 0 | 0 | 0 |  |  |
| `pinctrl-mtk-common-v2_debug.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `pinctrl-mtk-v2.ko` | Byte-identical | 101 | 0 | 0 | 0 | 0 |  |  |
| `pmic_lbat_service.ko` | Byte-identical | 30 | 0 | 0 | 0 | 0 |  |  |
| `pmic_lvsys_notify.ko` | Byte-identical | 9 | 0 | 0 | 0 | 0 |  |  |
| `powerhal_cpu_ctrl.ko` | Byte-identical | 42 | 0 | 0 | 0 | 0 |  |  |
| `pwm-mtk-disp.ko` | Byte-identical | 10 | 0 | 0 | 0 | 0 |  |  |
| `regulator-vibrator.ko` | Byte-identical | 9 | 0 | 0 | 0 | 0 |  |  |
| `reset-ti-syscon.ko` | Byte-identical | 7 | 0 | 0 | 0 | 0 |  |  |
| `rpmb.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `rps_perf.ko` | Byte-identical | 1 | 0 | 0 | 0 | 0 |  |  |
| `rt_pd_manager.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `rtc-mt6397.ko` | Byte-identical | 27 | 0 | 0 | 0 | 0 |  |  |
| `sc8551x_charger.ko` | Byte-identical | 36 | 0 | 0 | 0 | 0 |  |  |
| `scheduler.ko` | Byte-identical | 623 | 0 | 0 | 0 | 0 |  |  |
| `scp.ko` | Byte-identical | 203 | 0 | 0 | 0 | 0 |  |  |
| `sec-rng.ko` | Byte-identical | 6 | 0 | 0 | 0 | 0 |  |  |
| `sec.ko` | Byte-identical | 47 | 0 | 0 | 0 | 0 |  |  |
| `simtray.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `slg_verify.ko` | Byte-identical | 67 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-aw87xx.ko` | Byte-identical | 133 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-mt6359.ko` | Byte-identical | 86 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-mt6833-afe.ko` | Byte-identical | 148 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-mtk-common.ko` | Byte-identical | 83 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-rt5509.ko` | Byte-identical | 58 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-sipa-tuning.ko` | Byte-identical | 9 | 0 | 0 | 0 | 0 |  |  |
| `snd-soc-sipa.ko` | Byte-identical | 93 | 0 | 0 | 0 | 0 |  |  |
| `spi-mt65xx.ko` | Byte-identical | 35 | 0 | 0 | 0 | 0 |  |  |
| `spi_slave.ko` | Byte-identical | 15 | 0 | 0 | 0 | 0 |  |  |
| `spmi-mtk-pmif.ko` | Byte-identical | 64 | 0 | 0 | 0 | 0 |  |  |
| `sspm.ko` | Byte-identical | 52 | 0 | 0 | 0 | 0 |  |  |
| `sub2af.ko` | Byte-identical | 17 | 0 | 0 | 0 | 0 |  |  |
| `subaf.ko` | Byte-identical | 49 | 0 | 0 | 0 | 0 |  |  |
| `system_heap.ko` | Byte-identical | 97 | 0 | 0 | 0 | 0 |  |  |
| `task_turbo.ko` | Byte-identical | 158 | 0 | 0 | 0 | 0 |  |  |
| `tcpc_class.ko` | Byte-identical | 719 | 0 | 0 | 0 | 0 |  |  |
| `tcpc_mt6360.ko` | Byte-identical | 65 | 0 | 0 | 0 | 0 |  |  |
| `tcpci_late_sync.ko` | Byte-identical | 2 | 0 | 0 | 0 | 0 |  |  |
| `teeperf.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `thermal_monitor.ko` | Byte-identical | 895 | 0 | 0 | 0 | 0 |  |  |
| `timer-mediatek.ko` | Byte-identical | 16 | 0 | 0 | 0 | 0 |  |  |
| `touch_boost.ko` | Byte-identical | 49 | 0 | 0 | 0 | 0 |  |  |
| `trace_mmstat.ko` | Byte-identical | 21 | 0 | 0 | 0 | 0 |  |  |
| `trusted_mem.ko` | Byte-identical | 131 | 0 | 0 | 0 | 0 |  |  |
| `tui-common.ko` | Byte-identical | 5 | 0 | 0 | 0 | 0 |  |  |
| `ufs-mediatek-dbg.ko` | Byte-identical | 36 | 0 | 0 | 0 | 0 |  |  |
| `uload_ind.ko` | Byte-identical | 38 | 0 | 0 | 0 | 0 |  |  |
| `usb_meta.ko` | Byte-identical | 52 | 0 | 0 | 0 | 0 |  |  |
| `widevine_driver.ko` | Byte-identical | 8 | 0 | 0 | 0 | 0 |  |  |
| `wlan_drv_gen4m_6833.ko` | Byte-identical | 4758 | 0 | 0 | 0 | 0 |  | Wi-Fi: stock's also builds the MDDP offload (mgmt/mddp.c) |
| `wmt_chrdev_wifi.ko` | Byte-identical | 18 | 0 | 0 | 0 | 0 |  |  |
| `wmt_drv.ko` | Byte-identical | 1319 | 0 | 0 | 0 | 0 |  |  |
| `xiaomi_touch.ko` | Byte-identical | 73 | 0 | 0 | 0 | 0 |  |  |
| `xlogchar.ko` | Byte-identical | 11 | 0 | 0 | 0 | 0 |  |  |
| `xm_chg_dfs.ko` | Byte-identical | 12 | 0 | 0 | 0 | 0 |  |  |
| `arm_dsu_pmu.ko` | Byte-identical but stock's kernel | 22 | 0 | 0 | 0 | 0 |  |  |
| `cfg80211.ko` | Byte-identical but stock's kernel | 1659 | 0 | 0 | 0 | 0 |  |  |
| `drm_display_helper.ko` | Byte-identical but stock's kernel | 208 | 0 | 0 | 0 | 0 |  |  |
| `drm_dma_helper.ko` | Byte-identical but stock's kernel | 19 | 0 | 0 | 0 | 0 |  |  |
| `industrialio-triggered-buffer.ko` | Byte-identical but stock's kernel | 4 | 0 | 0 | 0 | 0 |  |  |
| `kfifo_buf.ko` | Byte-identical but stock's kernel | 14 | 0 | 0 | 0 | 0 |  |  |
| `libarc4.ko` | Byte-identical but stock's kernel | 2 | 0 | 0 | 0 | 0 |  |  |
| `mac80211.ko` | Byte-identical but stock's kernel | 1570 | 0 | 0 | 0 | 0 |  |  |
| `phy-generic.ko` | Byte-identical but stock's kernel | 13 | 0 | 0 | 0 | 0 |  |  |
| `reboot-mode.ko` | Byte-identical but stock's kernel | 7 | 0 | 0 | 0 | 0 |  |  |
| `rfkill.ko` | Byte-identical but stock's kernel | 44 | 0 | 0 | 0 | 0 |  |  |
| `rpmb-mtk.ko` | Byte-identical but stock's kernel | 20 | 0 | 0 | 0 | 0 |  |  |
| `syscon-reboot-mode.ko` | Byte-identical but stock's kernel | 4 | 0 | 0 | 0 | 0 |  |  |
| `ufs-mediatek-mod.ko` | Byte-identical but stock's kernel | 693 | 0 | 0 | 0 | 0 |  |  |
| `v4l2-flash-led-class.ko` | Byte-identical but stock's kernel | 9 | 0 | 0 | 0 | 0 |  |  |
| `mali_kbase_mt6833_r49.ko` | Code and data identical | 1526 | 0 | 0 | 0 | 0 | .modinfo |  |
| `mediatek-drm.ko` | Code and data identical | 2983 | 0 | 0 | 0 | 0 | .init.eh_frame, .llvm_addrsig, .rela.data, .rela.eh_frame, .rela.init.text, .rela.rodata, .rela.text, .rela___ksymtab+disp_sec_cb, .rodata.str1.1, .strtab, .symtab, .text, __bug_table, __kcrctab | display: stock's also builds MIUI's mi_dsi_panel.c |
| `mitee.ko` | Code and data identical | 114 | 0 | 0 | 0 | 0 | .modinfo, __bug_table |  |
| `mt6359p_battery.ko` | Code and data identical | 349 | 0 | 0 | 0 | 0 | __kcrctab, __versions |  |
| `mtk_battery_manager.ko` | Code and data identical | 55 | 0 | 0 | 0 | 0 | __versions |  |
| `mtk_chg_type_det.ko` | Code and data identical | 8 | 0 | 0 | 0 | 0 | .modinfo |  |
| `panel-n17-36-02-0a-dsc-vdo.ko` | Code and data identical | 31 | 0 | 0 | 0 | 0 | __versions |  |
| `st21nfc.ko` | Code and data identical | 26 | 0 | 0 | 0 | 0 | .modinfo |  |
| `stick_verify.ko` | Code and data identical | 160 | 0 | 0 | 0 | 0 | .modinfo, __bug_table |  |
| `switch_class.ko` | Code and data identical | 8 | 0 | 0 | 0 | 0 | __kcrctab_gpl |  |
| `binder_gki.ko` | Differs | 7 | 3 | 0 | 0 | 0 | size of .rela.text, .text |  |
| `mtk_charger_framework.ko` | Differs | 144 | 3 | 0 | 0 | 0 | size of .rela.text, .text |  |
| `mtk_pep50.ko` | Differs | 104 | 2 | 0 | 0 | 0 | size of .rela.text, .text |  |

## Stock modules without published source

| Module | Note |
| --- | --- |
