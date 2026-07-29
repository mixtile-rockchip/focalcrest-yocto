# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

SUMMARY = "CDC-ECM USB gadget debug link"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://focalcrest-usb-gadget \
    file://focalcrest-usb-gadget.service \
"

S = "${UNPACKDIR}"

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = "focalcrest-usb-gadget.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
	install -d ${D}${sbindir}
	install -m 0755 ${UNPACKDIR}/focalcrest-usb-gadget ${D}${sbindir}/

	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${UNPACKDIR}/focalcrest-usb-gadget.service \
		${D}${systemd_system_unitdir}/
}

RDEPENDS:${PN} = "focalcrest-net-conf"
