# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE:rk3566-focalcrest-az07 = "rk3566-focalcrest-az07"

SRC_URI:append:az07 = " \
    file://defconfig \
    file://rk3566-focalcrest-az07.dts \
"

do_configure:prepend:az07() {
	install -m 0644 ${UNPACKDIR}/rk3566-focalcrest-az07.dts \
		${S}/arch/arm64/boot/dts/rockchip/
	if ! grep -q "rk3566-focalcrest-az07.dtb" \
			${S}/arch/arm64/boot/dts/rockchip/Makefile; then
		echo 'dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3566-focalcrest-az07.dtb' \
			>> ${S}/arch/arm64/boot/dts/rockchip/Makefile
	fi
}
