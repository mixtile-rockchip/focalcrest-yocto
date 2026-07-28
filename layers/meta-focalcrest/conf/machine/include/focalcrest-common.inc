# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

MACHINEOVERRIDES =. "focalcrest:"

IMAGE_FSTYPES:append = " ext4 tar.zst"

WKS_FILE = "focalcrest-emmc.wks.in"
FC_BOOT_SIZE          ?= "128M"
FC_ROOTFS_EXTRA_SPACE ?= "256"
WICVARS:append = " FC_BOOT_SIZE FC_ROOTFS_EXTRA_SPACE"

MACHINE_FEATURES:append = " usbhost usbgadget rtc vfat"
MACHINE_EXTRA_RRECOMMENDS += "kernel-modules"

# 引导走自定义 FIT bootcmd, 不用 extlinux
UBOOT_EXTLINUX = "0"
MACHINE_ESSENTIAL_EXTRA_RDEPENDS:remove = "u-boot-extlinux"
IMAGE_BOOT_FILES = "fitImage;kernel.fit"

UBOOT_SIGN_ENABLE ?= "0"
FIT_GENERATE_KEYS ?= "0"
