# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

SOC_FAMILY = "rk3576"

DEFAULTTUNE ?= "cortexa72-cortexa53"

ROCKCHIP_CLOSED_TPL ?= "1"

require conf/machine/include/soc-family.inc
require conf/machine/include/rockchip-defaults.inc
require conf/machine/include/arm/armv8a/tune-cortexa72-cortexa53.inc
require conf/machine/include/rockchip-wic.inc
require conf/machine/include/focalcrest-common.inc

MACHINEOVERRIDES =. "focalcrest-rk3576:"

PREFERRED_PROVIDER_trusted-firmware-a = "rockchip-rkbin-tf-a"
PREFERRED_PROVIDER_optee-os = "rockchip-rkbin-optee-os"

UBOOT_SUFFIX ?= "itb"

SERIAL_CONSOLES ?= "1500000;ttyS0"

KBUILD_DEFCONFIG = ""

UBOOT_ENTRYPOINT   = "0x42000000"
UBOOT_LOADADDRESS  = "0x42000000"
FC_OPTEE_LOAD_ADDR = "0x48400000"
