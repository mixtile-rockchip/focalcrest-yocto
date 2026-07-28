# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

SUMMARY = "AP6256 (BCM43456) WiFi/BT 固件"
DESCRIPTION = "上游 linux-firmware 只有 43455, 不含 43456。"

LICENSE = "Firmware-broadcom_bcm43xx"
LICENSE_FLAGS = "commercial"
LIC_FILES_CHKSUM = "file://LICENCE.broadcom_bcm43xx;md5=3160c14df7228891b868060e1951dfbc"
NO_GENERIC_LICENSE[Firmware-broadcom_bcm43xx] = "LICENCE.broadcom_bcm43xx"

SRC_URI = "\
    file://LICENCE.broadcom_bcm43xx \
    file://brcmfmac43456-sdio.bin \
    file://brcmfmac43456-sdio.txt \
    file://BCM4345C5.hcd \
"

S = "${UNPACKDIR}"

inherit allarch

do_install() {
	install -d ${D}${nonarch_base_libdir}/firmware/brcm
	install -m 0644 ${UNPACKDIR}/brcmfmac43456-sdio.bin ${D}${nonarch_base_libdir}/firmware/brcm/
	install -m 0644 ${UNPACKDIR}/brcmfmac43456-sdio.txt ${D}${nonarch_base_libdir}/firmware/brcm/
	install -m 0644 ${UNPACKDIR}/BCM4345C5.hcd          ${D}${nonarch_base_libdir}/firmware/brcm/
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/brcm"

INHIBIT_DEFAULT_DEPS = "1"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
EXCLUDE_FROM_SHLIBS = "1"

RDEPENDS:${PN} += "linux-firmware-broadcom-license"
