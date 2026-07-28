# meta-focalcrest

Focalcrest Rockchip Yocto BSP layer.

* Yocto baseline: **6.0 "wrynose"** (LTS, supported until 2030-04)
* Kernel: `linux-yocto 6.18`, `PREEMPT_RT` enabled
* U-Boot: `2026.07`
* Layer dependencies: `openembedded-core`, `meta-openembedded`, `meta-arm`,
  `meta-rockchip` (all on the wrynose branch)

## Layering

| Level | File | Responsibility |
|---|---|---|
| Distro | `conf/distro/focalcrest.conf` | `DISTRO_FEATURES`, `INIT_MANAGER`, package format |
| | `conf/distro/include/focalcrest-versions.inc` | Kernel / U-Boot version pinning |
| Company | `conf/machine/include/focalcrest-common.inc` | Partition table, image formats, FIT boot flow, `focalcrest` override |
| SoC | `conf/machine/include/focalcrest-rk3566.inc` | Pulls in upstream `rk3566.inc`, console, load addresses, `KBUILD_DEFCONFIG` |
| | `conf/machine/include/focalcrest-rk3576.inc` | Same role; upstream has no `rk3576.inc`, so the SoC glue is built here |
| | `conf/machine/include/focalcrest-rk3588s.inc` | Pulls in upstream `rk3588s.inc`; also pins `SOC_FAMILY` so the rkbin blob names resolve |
| Board | `conf/machine/rk3566-autonomic-m1.conf` | DTB, U-Boot defconfig, on-board peripherals |

`MACHINEOVERRIDES` ends up as
`az07:focalcrest-rk3566:focalcrest:aarch64:rockchip:closed-tpl:rk3566:…`, so
recipes can append at company / SoC / board granularity:

```bitbake
SRC_URI:append:focalcrest        = " …"   # every Focalcrest board
SRC_URI:append:focalcrest-rk3566 = " …"   # every Focalcrest RK3566 board
SRC_URI:append:az07              = " …"   # AZ07 only
```

* **Adding a board** → new `conf/machine/<soc>-focalcrest-<board>.conf`
* **Adding a SoC** → new `conf/machine/include/focalcrest-<soc>.inc`

## Supported machines

### `rk3566-focalcrest-az07`

Rockchip RK3566, eMMC-only.

| Peripheral | Configuration |
|---|---|
| eMMC | `sdhci` / `rk3568-dwcmshc`, 8-bit HS200 1.8 V, 200 MHz, non-removable |
| SD slot | `sdmmc0`, 4-bit SDR104 150 MHz, `vmmc` = `vcc3v3_sd` (gpio0 PA5), `vqmmc` = `vccio_sd` |
| USB | OTG (`usb_host0_xhci`, high-speed only on RK3566), USB3 host (`usb_host1_xhci` + `combphy1`), 2× USB2 host (`usb_host{0,1}_{ehci,ohci}`) |
| LED | `gpio-leds`, `sys_status_led` @ gpio0 PB7, heartbeat by default |
| Thermal | `tsadc`, TSHUT in GPIO mode / active low; reuses the `rk356x-base.dtsi` thermal-zones (throttle at 70/75 °C, shutdown at 95 °C) |
| ADC | `saradc`, `vref-supply` = `vcc_1v8` |
| WiFi | AP6256 (BCM43456) on `sdmmc1`, 4-bit SDR104 150 MHz |
| Bluetooth | BCM4345C5 on `uart1` (m0 pins), hardware flow control, `max-speed = 3000000` |
| mmc numbering | `mmc0` = eMMC, `mmc1` = SD slot, `mmc2` = WiFi SDIO (pinned via `aliases`) |
| PMIC | RK817 @ i2c0 0x20, 13 rails |
| CPU regulator | `vdd_cpu` = RK8602 @ i2c0 0x42 (712.5 mV – 1.2 V) |
| RTC | PCF8563 @ i2c5 0x51, also supplies 32.768 kHz to WiFi |
| IO domains | `pmu_io_domains`, nine rails mapped |
| OP-TEE | 16 MiB reserved memory @ `0x08400000` |
| Console | UART2 @ 1500000 8N1 |

**Not enabled**: display (VOP2/DSI/HDMI), I2S audio, SPI, PCIe, Ethernet. Add
them in the board DTS when needed. Ethernet is not routed on the hardware — the
RK3566 GMAC is unused on AZ07.

`CONFIG_ROCKCHIP_THERMAL` is `=y` rather than `=m`: the thermal driver only
writes `rockchip,hw-tshut-temp` when it probes, so as a module there would be
neither throttling nor hardware shutdown between power-on and module load.

**Pending schematic confirmation**

* WiFi host-wake is assumed to be `gpio2 RK_PB2`.
* `vccio_flash` is an assumed fixed 1.8 V rail (`vccio2-supply` of `pmu_io_domains`).
* `saradc`'s `vref-supply` is set to `vcc_1v8`; RK817 also has LDO_REG8 named
  `vcc1v8_adc`, which may be the actual net. Both are 1.8 V and `always-on`, and
  `vref-supply` only affects enable and range scaling, so the current wiring is
  functionally equivalent.
* Whether the `tsadc` TSHUT pin reaches the PMIC is unconfirmed. If it does not,
  the hardware shutdown under `hw-tshut-mode = <1>` will not fire, but the
  thermal-zones software throttling and the 95 °C critical shutdown still work.

### `rk3566-autonomic-m1`

Autonomic M1, Rockchip RK3566. The device tree was migrated from the Rockchip
5.10 vendor tree into mainline style and validated on hardware; the DTB built by
Yocto is byte-identical to the reference DTB.

Same SoC, same PMIC (RK817 + RK8602) and same WiFi/BT module (AP6256) as AZ07;
the differences are below.

| Peripheral | Configuration |
|---|---|
| eMMC | `sdhci`, 8-bit HS200 1.8 V, 200 MHz, non-removable, `vqmmc` = `vcc_1v8` |
| SD slot | `sdmmc0`, 4-bit SDR104 150 MHz, `vmmc` = `vcc3v3_sd` (gpio0 PA5) |
| Ethernet | `gmac1` RGMII + RTL8211F @ mdio1 addr 0, `gmac1m0_*` pin groups, reset gpio4 PC1, `tx_delay = 0x4f` / `rx_delay = 0x25`, external 125 MHz `gmac1_clkin` |
| WiFi | AP6256 (BCM43456) on `sdmmc1`, SDR104 |
| Bluetooth | BCM4345C5 on `uart1` (m0 pins), `max-speed = 1500000` |
| RTC | HYM8563 @ i2c3 0x51 |
| PMIC | RK817 @ i2c0 0x20; CPU regulator RK8602 @ i2c0 0x42 |
| Audio | SPDIF output (`linux,spdif-dit`) |
| GPU | Mali, `panfrost`, `mali-supply` = `vdd_gpu` |
| Keys | adc-keys, saradc ch0, recovery @ 2 mV |
| LED | Three: `sys_status_led` (gpio0 PB7), `power_status_led` (gpio0 PA0), `power_ctrl` (gpio1 PA5) |
| USB | OTG (`usb_host0_xhci`) + USB3 host (`usb_host1_xhci` + `combphy1`), host supply gpio1 PA6 |
| Console | UART2 @ 1500000 8N1 |

**defconfig delta against AZ07** — four lines only:

```
CONFIG_RTC_DRV_HYM8563=y          # AZ07 uses PCF8563
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_SND_SOC_SPDIF=m            # spdif-dit codec
CONFIG_KEYBOARD_ADC=y
```

`CONFIG_RTC_DRV_HYM8563` is `=y` rather than `=m`: both `sdio_pwrseq` and the
Bluetooth node use `&hym8563` as their 32.768 kHz source, so as a module WiFi/BT
would have to rely on deferred probe.

**Not enabled**

Display (VOP2 / HDMI) is deliberately off. The following parts have no mainline
driver as of 6.18 and are not modelled in the DTS: IT6620 HDMI eARC RX, ES9821
ADC (SPI0), ES9033 DAC (SPI1), HUSB311 USB-C TCPC.

**M1's main audio path therefore cannot work in this round** — the presence of a
`spdif-sound` node does not mean audio is up; only SPDIF output is usable.
`&gpu` is enabled and `DRM_PANFROST=m`, but the distro opts out of x11/wayland,
so panfrost only provides a render node with no display output.

**Pending schematic confirmation**

* `power_ctrl` (gpio1 PA5) is modelled as a gpio-led with `default-state = "off"`.
  If it is actually a power-enable pin, the kernel will turn it off on boot.
* Both `sys_status_led` and `power_status_led` carry a heartbeat trigger; the
  latter is most likely copy-paste.
* `vcc3v3_sd` has `vin-supply = <&vccio_sd>`, but `vccio_sd` is a 1.8–3.3 V
  adjustable LDO. A fixed 3.3 V rail parented to an adjustable one does not make
  sense (AZ07 parents it to `vcc_3v3`).
* `&i2c1`, `&i2c4` and `&uart0` are set to okay but have no child nodes.

### `rk3576s-focalcrest-az08`

FocalCrest AZ08, Rockchip **RK3576S** — the first non-RK3566 board in this layer,
which is why the SoC-level `focalcrest-rk3576.inc` was added alongside it. The
822-line mainline-style device tree came from hardware engineering and is
included verbatim.

Structural differences against the two RK3566 boards:

| Item | RK3566 boards | AZ08 (RK3576S) |
|---|---|---|
| CPU / tune | 4× A55, `cortexa55` (armv8.2-a) | 4× A72 + 4× A53, `cortexa72-cortexa53` (armv8.0-a) |
| DRAM base | `0x00000000` | `0x40000000` |
| Kernel load (FIT) | `0x02000000` | `0x42000000` |
| OP-TEE | `0x08400000` | `0x48400000` |
| env `loadaddr` | `0x0a000000` | `0x4a000000` |
| Console | UART2 → `ttyS2` | UART0 → `ttyS0` (`serial0 = &uart0` in `rk3576.dtsi`) |

Peripherals:

| Peripheral | Configuration |
|---|---|
| eMMC | `sdhci`, 8-bit **HS400 + enhanced strobe**, 200 MHz, non-removable, `vmmc` = `vcc_3v3_s3`, `vqmmc` = `vcc_1v8_s3`, **CQE disabled** |
| SD slot | `sdmmc`, 4-bit SDR104, `vmmc` = `vcc3v3_sd` (gpio0 PB6), `vqmmc` = `vccio_sd_s0` |
| SPI NOR | Two `jedec,spi-nor`: `spi1` (m1 pins) and `spi3` (m2 pins, csn0/csn1), 10 MHz each |
| USB | `usb_drd0_dwc3` in **peripheral mode only** (`u2phy0` + `usbdp_phy`); `usb_drd1_dwc3` **disabled** — see Known issues |
| WiFi | AP6256 (BCM43456) on `sdio`, SDR104, `sdio_pwrseq` reset gpio1 PC6, host-wake gpio0 PB0 |
| Bluetooth | BCM4345C5 on `uart4` (m1 pins), hardware flow control, BT_REG_ON gpio1 PC7 |
| PMIC | **RK806 @ i2c1 0x23** (the other two boards use RK817 @ i2c0); no separate CPU regulator, the big and little clusters are fed by `vdd_cpu_big_s0` / `vdd_cpu_lit_s0` |
| RTC | HYM8563 @ i2c2 0x51 |
| Keys | Two adc-keys groups: saradc ch0 = boot, ch1 = recovery |
| LED | `gpio-leds`, `sys_status_led` @ gpio0 PC4, heartbeat |
| GPU | Mali, `mali-supply` = `vdd_gpu_s0` |
| Thermal / ADC | `tsadc`, `saradc` (`vref-supply` = `vcca_1v8_s0`) |
| mmc numbering | `mmc0` = eMMC, `mmc1` = SD slot, `mmc2` = WiFi SDIO (pinned via `aliases`; mainline `rk3576.dtsi` has no mmc aliases) |
| Ethernet | **None** — the RK3576S variant has no GMAC at all; the vendor `rk3576s.dtsi` deletes `gmac0`/`gmac1`, and the RK3576S datasheet lists no Ethernet |

**defconfig delta against AZ07** (AZ08's defconfig is derived from AZ07's):

```
CONFIG_RTC_DRV_HYM8563=y          # AZ07 uses PCF8563
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_KEYBOARD_ADC=y             # two adc-keys groups
CONFIG_TYPEC=y                    # hard dependency of PHY_ROCKCHIP_USBDP
CONFIG_PHY_ROCKCHIP_USBDP=y       # usbdp_phy, required for drd0
CONFIG_SERIAL_8250_NR_UARTS=12    # RK3576 has 12 UARTs, Bluetooth sits on uart4
CONFIG_SERIAL_8250_RUNTIME_UARTS=12
CONFIG_MTD=y                      # the two NOR flashes on spi1 / spi3
CONFIG_MTD_BLOCK=y
CONFIG_MTD_SPI_NOR=y
```

`CONFIG_RTC_DRV_HYM8563` is `=y` for the same reason as on M1.

**Validated on hardware**: boot chain (idbloader + u-boot.itb with bl31 v1.15 and
OP-TEE v1.05 + kernel.fit), eMMC HS400 enhanced strobe 7.30 GiB, SD slot, WiFi
(SDIO SDR104, BCM4345/9 firmware, scanning both 2.4 and 5 GHz), Bluetooth
(BCM4345C5, BT 5.2), CDC-ECM debug link over drd0.

### `rk3588s-focalcrest-az04b`

Focalcrest AZ04B, Rockchip **RK3588S**. Unlike RK3576, upstream `meta-rockchip`
already ships `rk3588s.inc` *and* the rk3588s rkbin blob entries, so
`focalcrest-rk3588s.inc` only layers the Focalcrest conventions on top and this
layer carries **no rkbin bbappend** for the SoC.

rkbin deploys the shared 3588/3588S blobs as `ddr-rk3588.bin` / `tee-rk3588.bin`,
but `rk3588s.inc` leaves `SOC_FAMILY` at `rk3588s`, and both `ROCKCHIP_TPL` and
this layer's `do_fc_wrap_optee` look the blobs up by `SOC_FAMILY`. So
`focalcrest-rk3588s.inc` pins `SOC_FAMILY = "rk3588"`, exactly as upstream's own
`rk3588.inc` does.

Structural differences against the other boards:

| Item | RK3566 boards | AZ08 (RK3576S) | AZ04B (RK3588S) |
|---|---|---|---|
| CPU / tune | 4× A55, `cortexa55` | 4× A72 + 4× A53, `cortexa72-cortexa53` | 4× A76 + 4× A55, `cortexa76-cortexa55-crypto` (armv8.2-a) |
| DRAM base | `0x00000000` | `0x40000000` | `0x00000000` |
| Kernel load (FIT) | `0x02000000` | `0x42000000` | `0x02000000` |
| OP-TEE | `0x08400000` | `0x48400000` | `0x08400000` |
| env `loadaddr` | `0x0a000000` | `0x4a000000` | `0x0a000000` |
| Console | UART2 → `ttyS2` | UART0 → `ttyS0` | UART2 → `ttyS2` |
| PMIC bus | RK817 on i2c0 | RK806 on i2c1 | **RK806 on spi2** |
| SoC glue | upstream `rk3566.inc` | written in this layer | upstream `rk3588s.inc` |

Peripherals:

| Peripheral | Configuration |
|---|---|
| eMMC | `sdhci` / `rk3588-dwcmshc`, 8-bit HS400 + enhanced strobe, 200 MHz, non-removable, `vmmc` = `vcc_3v3_s0`, `vqmmc` = `vcc_1v8_s3`, CQE not enabled |
| SD slot | `sdmmc`, 4-bit SDR104 150 MHz, `vmmc` = `vcc_3v3_sd_s3`, `vqmmc` = `vccio_sd_s0` |
| SPI NOR | One `jedec,spi-nor` on `spi0` (m2 pins), 50 MHz |
| PMIC | RK806 on `spi2` (m2 pins, cs0), 1 MHz, `system-power-controller` |
| CPU regulators | RK8602 @ i2c0 0x42 (`vdd_cpu_big0_s0`) + RK8603 @ i2c0 0x43 (`vdd_cpu_big1_s0`); little cluster on RK806 `dcdc-reg2` |
| NPU regulator | RK8602 @ i2c2 0x42 (`vdd_npu_s0`) |
| NPU | `rknn_core_0..2` + `rknn_mmu_0..2`, mainline `rocket` accel driver |
| GPU | Mali G610, `rockchip,rk3588-mali` → **panthor** (not panfrost) |
| PCIe | `pcie2x1l2` (2.0 x1), PERST# gpio3 PD1, `vpcie3v3` = `vcc3v3_pcie20`; `combphy0_ps` + `combphy2_psu` |
| USB-C | HUSB311 TCPC @ i2c1 0x4e via the generic `tcpci` fallback, dual-role, role switch → `usb_host0_xhci`, orientation switch → `usbdp_phy0` |
| USB | OTG (`usb_host0_xhci`), USB3 host (`usb_host2_xhci`), 2× USB2 host (`usb_host{0,1}_{ehci,ohci}`) |
| WiFi | AP6256 (BCM43456) on `sdio` (m1 pins), SDR104, `sdio_pwrseq` reset gpio3 PC4, host-wake gpio0 PA0 |
| Bluetooth | BCM4345C5 on `uart9` (m2 pins), hardware flow control, `max-speed = 3000000`, BT_REG_ON gpio3 PC1 |
| RTC | HYM8563 @ i2c3 0x51, also the WiFi/BT 32.768 kHz source |
| Fan | `pwm-fan` on `pwm2`, tacho on gpio0 PC5, 4 active trips (40/50/60/65 °C) mapped off `package_thermal` |
| Keys | Two adc-keys groups: saradc ch0 = boot, ch1 = recovery |
| LED | `gpio-leds`, `sys_status_led` @ gpio0 PC2, heartbeat |
| Thermal / ADC | `tsadc`, `saradc` (`vref-supply` = `vcca_1v8_s0`) |
| mmc numbering | `mmc0` = eMMC, `mmc1` = SD slot, `mmc2` = WiFi SDIO (pinned via `aliases`) |
| Ethernet | Not enabled — the GMAC is not routed on this board |

**defconfig delta against AZ08** (AZ04B's defconfig is derived from AZ08's):

```
CONFIG_DRM_PANTHOR=m              # Mali G610 is valhall-csf, panfrost does not apply
# CONFIG_DRM_PANFROST is not set
CONFIG_DRM_ACCEL=y                # rknn_core / rknn_mmu
CONFIG_DRM_ACCEL_ROCKET=m
CONFIG_PCI=y                      # pcie2x1l2
CONFIG_PCI_MSI=y
CONFIG_PCIE_ROCKCHIP_DW_HOST=y
CONFIG_PHY_ROCKCHIP_NANENG_COMBO_PHY=y
CONFIG_TYPEC_TCPM=y               # HUSB311 / usb-c-connector
CONFIG_TYPEC_TCPCI=y
CONFIG_REGULATOR_FAN53555=y       # RK8602 / RK8603 bind through fan53555
CONFIG_PWM_ROCKCHIP=y             # pwm-fan on pwm2
CONFIG_MMC_SDHCI_OF_DWCMSHC=y     # rockchip,rk3588-dwcmshc
```

`CONFIG_PCIE_ROCKCHIP_DW` is a hidden symbol — select it through
`CONFIG_PCIE_ROCKCHIP_DW_HOST`, which additionally needs `CONFIG_PCI_MSI`.

The device tree came from hardware engineering in mainline style. Four vendor
leftovers were corrected on import: `mms-hs200-1_8v` → `mmc-hs200-1_8v`,
`interrupts-names` → `interrupt-names`, `haoyu,clock-is-critical` dropped (it is
in neither the 6.18 binding nor `rtc-hym8563.c`), and `supports-cqe` dropped.

**Not enabled**: display (VOP2 / HDMI / DP alt-mode), audio, Ethernet.
`usb_host1_xhci` is left off because `usbdp_phy1` is not described. The
`usb-c-connector` deliberately has no `port@2`, so DP alt-mode is not wired.

## Partition layout

`files/wic/focalcrest-emmc.wks.in`

| # | Partition | Offset / size | Content |
|---|---|---|---|
| 1 | `loader1` | LBA 64, 8128 K | `idbloader.img` (TPL DDR init + SPL) |
| 2 | `loader2` | LBA 16384, 8 M | `u-boot.itb` (U-Boot + bl31 + OP-TEE) |
| 3 | `boot` | 128 M, ext4, active | `kernel.fit` |
| 4 | `rootfs` | remainder, ext4 | `root=PARTLABEL=rootfs` |

The LBA 64 and LBA 16384 offsets are hard requirements of the Rockchip BootROM /
rkbin. Nothing is allocated after `rootfs`; the rest of the eMMC stays
unpartitioned.

The kernel FIT lives on its own `boot` partition rather than in the rootfs
`/boot`, so the kernel can be updated independently of the rootfs and U-Boot
never has to parse the rootfs — if the rootfs later becomes read-only or gains
dm-verity, the boot chain is unaffected.

## Boot chain

```
BootROM
 └─ idbloader.img @ LBA 64        TPL (DDR init) + SPL
     └─ u-boot.itb @ LBA 16384    u-boot + bl31 (TF-A) + tee (OP-TEE)
         └─ U-Boot proper
             bootcmd = run fc_bootcmd
             fc_bootcmd = part number mmc ${bootdev} ${bootpart} fcpart
                       && load mmc ${bootdev}:${fcpart} ${loadaddr} ${bootfit}
                       && bootm ${loadaddr}; reset
             └─ kernel.fit (kernel + DTB)
                 └─ root=PARTLABEL=rootfs, no initramfs
```

The default environment is defined by
`recipes-bsp/u-boot/files/rk3566-focalcrest-az07.env`
(`CONFIG_ENV_USE_DEFAULT_ENV_TEXT_FILE`). Partitions are looked up by **name**,
not by index, so changing the partition table only requires updating the
`bootpart` / `bootfit` variables.

## Quick start

```sh
cd <project root>
. ./setup-env.sh                      # defaults to build-az07
bitbake focalcrest-image-bringup      # the only image in this layer
```

Artifacts in `build-az07/tmp/deploy/images/rk3566-focalcrest-az07/`:

| File | Purpose |
|---|---|
| `*.rootfs-*.wic` | Full-disk image, `rkdeveloptool wl 0 <file>` |
| `*.wic.bmap` | Speeds up writing with `bmaptool` |
| `idbloader.img` | Flash LBA 64 on its own |
| `u-boot.itb` | Flash LBA 16384 on its own |
| `fitImage` | Kernel FIT (DTB included) |

## Implementation notes

The following are non-default choices; understand why before changing them.

**`KBUILD_DEFCONFIG = ""`** (board conf)
`rk3566.inc` sets `KBUILD_DEFCONFIG ?= "defconfig"`, and when it is non-empty
`kernel-yocto.bbclass` does a `cp -f` of the in-tree arm64 defconfig over the one
supplied through `SRC_URI`.

**`KCONFIG_MODE = "alldefconfig"` silently drops unsatisfiable symbols**
A defconfig symbol whose Kconfig dependencies are unmet is dropped without any
warning. `PHY_ROCKCHIP_USBDP` `depends on TYPEC`, so it was absent until
`CONFIG_TYPEC=y` was added. Check `depends on` first, and verify against the
generated `.config`, not the defconfig you wrote.

**`COMPATIBLE_MACHINE:<machine>`** (`linux-yocto_%.bbappend`)
`meta-rockchip`'s `linux-rockchip.inc` whitelists machines one by one; a new
board has to add its own entry.

**`PREFERRED_VERSION_u-boot = "2026.07"`** — must be an exact version
oe-core's u-boot has a devupstream variant (PV of the form `<ver>+git`, following
git master). A wildcard such as `"2026.07%"` matches it and builds a release
candidate instead.

**`DISTRO_FEATURES_OPTED_OUT`** (distro conf)
Setting `DISTRO_FEATURES` directly has no effect — `bitbake.conf` appends
`oe.utils.filter_default_features()` afterwards, which adds
`DEFAULTS − OPTED_OUT` back in.

**Three wks constraints** (`files/wic/focalcrest-emmc.wks.in`)
1. Every `part` must be a single line — ksparser runs `shlex.split` per line and
   does not support backslash continuations.
2. `--ondisk mmcblk0` must be explicit — the default is `sda`, which would make
   the generated fstab point at `/dev/sdaN`.
3. `--no-fstab-update` on a `part` has no effect — `update_fstab()` in
   `direct.py` does not check it, it reads the global wic CLI option. To get
   `/boot` into fstab safely, use `--use-label` plus
   `--fsoptions "defaults,nofail"`.

**OP-TEE inside u-boot.itb** (`u-boot_%.bbappend`)
`meta-rockchip` passes only `BL31=` and `ROCKCHIP_TPL=`, so binman skips its
`tee-os` entry and the rkbin bl31 (built with the opteed SPD) never gets a BL32.
This layer supplies `TEE=` and wraps the raw bl32 in an OP-TEE v1 header —
binman's ARM64 FIT template uses `fit,operation = "split-elf"` and rejects a raw
binary.

**OP-TEE needs a `reserved-memory` node in the kernel DTS**
`FC_OPTEE_LOAD_ADDR` sits inside the range the kernel would otherwise own.
Without a matching `no-map` reservation the kernel allocates and DMAs into
secure DRAM, and the firewall turns that into an asynchronous external abort
whose reported PC is unrelated to the real access. All three boards reserve
16 MiB.

**rkbin SoC whitelist** (`recipes-bsp/rkbin/*.bbappend`)
`rockchip-rkbin.inc` sets `COMPATIBLE_MACHINE = "^$"` and whitelists per SoC;
rk3576 is absent, so this layer adds one bbappend each for ddr / tf-a /
optee-os. The `ddr-rk3576.bin` deploy name is fixed by
`ROCKCHIP_TPL:closed-tpl = "${DEPLOY_DIR_IMAGE}/ddr-${SOC_FAMILY}.bin"`.

**The U-Boot board DTS must include `gpio.h` itself**
`rk3576.dtsi` does not include it; the upstream rk3576 board dts files all do.
Omitting it fails in `dtc` with `Unexpected 'GPIO_ACTIVE_LOW'` at a line inside
`rk3576.dtsi`, which looks like an upstream bug.

**`DEPENDS += "xxd-native"`** (`u-boot_%.bbappend`)
The rule that generates `defaultenv_autogenerated.h` for
`ENV_USE_DEFAULT_ENV_TEXT_FILE` uses `xxd -i`, which is not in Yocto's
HOSTTOOLS. In oe-core it is provided by the `vim` recipe (`PROVIDES = "xxd"`).

**After a DTS change build `linux-yocto-fitimage`, not `virtual/kernel`**
The FIT is assembled by a separate recipe (`rockchip-fitimage.inc` sets
`MACHINE_ESSENTIAL_EXTRA_RDEPENDS_KERNEL = "linux-yocto-fitimage"`).
`virtual/kernel` only refreshes `Image` and the `.dtb`, so `fitImage` keeps the
old kernel — with self-consistent hashes, which is easy to miss.

**Fast kernel swap during bring-up** (no full reflash)
`/boot` is a separate, read-write partition containing only `kernel.fit`:

```sh
scp fitImage root@<board>:/boot/kernel.fit.new
ssh root@<board> 'cd /boot && mv -f kernel.fit.new kernel.fit && sync && reboot'
```

Run `cp /boot/kernel.fit /boot/kernel.fit.bak` first; if the new kernel does not
boot, recover from U-Boot with
`load mmc 0:3 ${loadaddr} kernel.fit.bak && bootm`. One round takes about 20 s.

**bitbake does not allow comments inside quotes**
A `#` **inside** quotes in a `.bb` is not a comment — it is taken as a package
name, and an embedded double quote terminates the string early.

**Package name ≠ recipe name**
`wireless-regdb-static` (mutually exclusive with `wireless-regdb`, via
`RCONFLICTS`); `mesa` splits into `libegl-mesa` / `libgles2-mesa` / `libgbm` /
`libglapi` / `mesa-megadriver` (`${PN}` in `mesa.inc` has neither
`FILES:${PN}` nor `ALLOW_EMPTY`, so that package is not produced).

**`debug-tweaks` is deprecated** (as of wrynose)
Split into `allow-empty-password allow-root-login empty-root-password
post-install-logging serial-autologin-root`.

## Debug link

The image ships a CDC-ECM USB gadget (`focalcrest-usb-gadget`); connecting the
OTG port to a development host gives a point-to-point network:

```
board usb0 = 192.168.7.1     peer gets 192.168.7.10+ from networkd's built-in DHCP
ssh root@192.168.7.1         empty password
```

The MAC is derived from `machine-id` (stable across reboots) and `EmitRouter=no`
keeps it from taking over the default route, so the whole
DTS-change-to-validation loop needs neither a serial console nor a reflash.

## Known issues

| Item | Notes |
|---|---|
| eMMC tail unallocated | The image is smaller than the eMMC, so the backup GPT header is not at the end of the disk; run `sgdisk -e` + `resize2fs` on first boot |
| SDIO first init occasionally fails | `mmc2: error -5 whilst initialising SDIO card`, succeeds at SDR104 after a retry |
| `brcmfmac43456-sdio.clm_blob` missing | The kernel warns that available channels may be limited |
| AZ08: no USB host | `usb_drd1_dwc3` aborts on its first register read of `DWC3_GSNPSID`. No Rockchip RK3576S board file enables it; every board that does is a non-S RK3576 |
| AZ08: drd0 is peripheral-only | In `otg` mode mainline registers xhci and root-hub autosuspend triggers an SError. The vendor kernel has a `rockchip,rk3576-dwc3` runtime-PM patch in dwc3 core; mainline does not |
| AZ08: eMMC CQE disabled | `supports-cqe` is dropped with `/delete-property/`. With CQE on, the controller loops on `cqhci: Failed to halt` once real filesystem I/O starts |
| AZ08: SDIO runs at 148.5 MHz | `dw_mmc-rockchip` divides `cclk_src_sdio` by a fixed 2, and on RK3576 that clock tops out at gpll/4 = 297 MHz. RK356x has a `COMPOSITE_NODIV` mux with an exact 300 MHz tap. 1 % low, inside SDR104 tolerance |
