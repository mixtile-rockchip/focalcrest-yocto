# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

SUMMARY = "systemd-networkd configuration (usb0 / wlan0 / ethernet)"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://10-usb0.network \
    file://20-wlan.network \
    file://30-ether.network \
"

S = "${UNPACKDIR}"

inherit allarch

do_install() {
	install -d ${D}${systemd_unitdir}/network
	install -m 0644 ${UNPACKDIR}/10-usb0.network ${D}${systemd_unitdir}/network/
	install -m 0644 ${UNPACKDIR}/20-wlan.network ${D}${systemd_unitdir}/network/
	install -m 0644 ${UNPACKDIR}/30-ether.network ${D}${systemd_unitdir}/network/
}

FILES:${PN} = "${systemd_unitdir}/network"

RDEPENDS:${PN} = "systemd"
