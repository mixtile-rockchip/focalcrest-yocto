# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

require conf/machine/include/rk3566.inc
require conf/machine/include/focalcrest-common.inc

MACHINEOVERRIDES =. "focalcrest-rk3566:"

SERIAL_CONSOLES ?= "1500000;ttyS2"

# When non-empty, kernel-yocto overwrites the SRC_URI defconfig with the in-tree one
KBUILD_DEFCONFIG = ""

UBOOT_ENTRYPOINT  = "0x02000000"
UBOOT_LOADADDRESS = "0x02000000"
