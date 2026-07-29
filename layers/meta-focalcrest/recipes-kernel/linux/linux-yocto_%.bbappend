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

COMPATIBLE_MACHINE:rk3566-autonomic-m1 = "rk3566-autonomic-m1"

SRC_URI:append:autonomic-m1 = " \
    file://defconfig \
    file://rk3566-autonomic-m1.dts \
"

do_configure:prepend:autonomic-m1() {
	install -m 0644 ${UNPACKDIR}/rk3566-autonomic-m1.dts \
		${S}/arch/arm64/boot/dts/rockchip/
	if ! grep -q "rk3566-autonomic-m1.dtb" \
			${S}/arch/arm64/boot/dts/rockchip/Makefile; then
		echo 'dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3566-autonomic-m1.dtb' \
			>> ${S}/arch/arm64/boot/dts/rockchip/Makefile
	fi
}

COMPATIBLE_MACHINE:rk3576s-focalcrest-az08 = "rk3576s-focalcrest-az08"

SRC_URI:append:az08 = " \
    file://defconfig \
    file://rk3576s-focalcrest-az08.dts \
"

do_configure:prepend:az08() {
	install -m 0644 ${UNPACKDIR}/rk3576s-focalcrest-az08.dts \
		${S}/arch/arm64/boot/dts/rockchip/
	if ! grep -q "rk3576s-focalcrest-az08.dtb" \
			${S}/arch/arm64/boot/dts/rockchip/Makefile; then
		echo 'dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3576s-focalcrest-az08.dtb' \
			>> ${S}/arch/arm64/boot/dts/rockchip/Makefile
	fi
}
