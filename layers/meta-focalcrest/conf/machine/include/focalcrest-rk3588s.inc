# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

require conf/machine/include/rk3588s.inc
require conf/machine/include/focalcrest-common.inc

MACHINEOVERRIDES =. "focalcrest-rk3588s:"

# rkbin ships one set of blobs for both the rk3588 and the rk3588s, deployed as
# ddr-rk3588.bin / tee-rk3588.bin. ROCKCHIP_TPL and do_fc_wrap_optee look them
# up by SOC_FAMILY, so it has to say rk3588 (upstream rk3588.inc does the same).
SOC_FAMILY = "rk3588"

SERIAL_CONSOLES ?= "1500000;ttyS2"

# When non-empty, kernel-yocto overwrites the SRC_URI defconfig with the in-tree one
KBUILD_DEFCONFIG = ""

UBOOT_ENTRYPOINT  = "0x02000000"
UBOOT_LOADADDRESS = "0x02000000"
