# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:az07 = " \
    file://rk3566-focalcrest-az07.dts \
    file://rk3566-focalcrest-az07-u-boot.dtsi \
    file://rk3566-focalcrest-az07_defconfig \
    file://rk3566-focalcrest-az07.env \
"

do_compile[depends] += "rockchip-rkbin-optee-os:do_deploy"

FC_OPTEE_LOAD_ADDR ?= "0x08400000"

python do_fc_wrap_optee() {
    import struct, os
    socs = {'focalcrest-rk3566', 'focalcrest-rk3576', 'focalcrest-rk3588s'}
    if not socs & set(d.getVar('MACHINEOVERRIDES').split(':')):
        return
    src = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),
                       'tee-%s.bin' % d.getVar('SOC_FAMILY'))
    dst = os.path.join(d.getVar('WORKDIR'), 'tee-optee-v1.bin')
    with open(src, 'rb') as f:
        blob = f.read()
    if blob[0:5] == b'OPTE\x01':
        bb.note("rkbin bl32 is already in OP-TEE v1 format, using as-is")
        payload = blob
    else:
        addr = int(d.getVar('FC_OPTEE_LOAD_ADDR'), 16)
        hdr = b'OPTE' + bytes([1]) + struct.pack('<H', 0) + bytes([2])
        hdr += struct.pack('<5I', len(blob), addr >> 32, addr & 0xffffffff, 0, 0)
        assert len(hdr) == 0x1c, len(hdr)
        payload = hdr + blob
        bb.note("wrapped rkbin bl32 (%d bytes) in an OP-TEE v1 header, load=0x%x"
                % (len(blob), addr))
    with open(dst, 'wb') as f:
        f.write(payload)
}
addtask fc_wrap_optee after do_configure before do_compile
do_fc_wrap_optee[depends] += "rockchip-rkbin-optee-os:do_deploy"

EXTRA_OEMAKE:append:focalcrest-rk3566 = " TEE=${WORKDIR}/tee-optee-v1.bin"
EXTRA_OEMAKE:append:focalcrest-rk3576 = " TEE=${WORKDIR}/tee-optee-v1.bin"
EXTRA_OEMAKE:append:focalcrest-rk3588s = " TEE=${WORKDIR}/tee-optee-v1.bin"

DEPENDS:append:focalcrest-rk3566 = " xxd-native"
DEPENDS:append:focalcrest-rk3576 = " xxd-native"
DEPENDS:append:focalcrest-rk3588s = " xxd-native"

do_configure:prepend:az07() {
	install -m 0644 ${UNPACKDIR}/rk3566-focalcrest-az07.dts \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3566-focalcrest-az07-u-boot.dtsi \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3566-focalcrest-az07_defconfig \
		${S}/configs/
	install -d ${S}/board/focalcrest/az07
	install -m 0644 ${UNPACKDIR}/rk3566-focalcrest-az07.env \
		${S}/board/focalcrest/az07/
}

SRC_URI:append:autonomic-m1 = " \
    file://rk3566-autonomic-m1.dts \
    file://rk3566-autonomic-m1-u-boot.dtsi \
    file://rk3566-autonomic-m1_defconfig \
    file://rk3566-autonomic-m1.env \
"

do_configure:prepend:autonomic-m1() {
	install -m 0644 ${UNPACKDIR}/rk3566-autonomic-m1.dts \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3566-autonomic-m1-u-boot.dtsi \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3566-autonomic-m1_defconfig \
		${S}/configs/
	install -d ${S}/board/autonomic/m1
	install -m 0644 ${UNPACKDIR}/rk3566-autonomic-m1.env \
		${S}/board/autonomic/m1/
}

SRC_URI:append:az08 = " \
    file://rk3576s-focalcrest-az08.dts \
    file://rk3576s-focalcrest-az08-u-boot.dtsi \
    file://rk3576s-focalcrest-az08_defconfig \
    file://rk3576s-focalcrest-az08.env \
"

do_configure:prepend:az08() {
	install -m 0644 ${UNPACKDIR}/rk3576s-focalcrest-az08.dts \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3576s-focalcrest-az08-u-boot.dtsi \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3576s-focalcrest-az08_defconfig \
		${S}/configs/
	install -d ${S}/board/focalcrest/az08
	install -m 0644 ${UNPACKDIR}/rk3576s-focalcrest-az08.env \
		${S}/board/focalcrest/az08/
}

SRC_URI:append:az04b = " \
    file://rk3588s-focalcrest-az04b.dts \
    file://rk3588s-focalcrest-az04b-u-boot.dtsi \
    file://rk3588s-focalcrest-az04b_defconfig \
    file://rk3588s-focalcrest-az04b.env \
"

do_configure:prepend:az04b() {
	install -m 0644 ${UNPACKDIR}/rk3588s-focalcrest-az04b.dts \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3588s-focalcrest-az04b-u-boot.dtsi \
		${S}/arch/arm/dts/
	install -m 0644 ${UNPACKDIR}/rk3588s-focalcrest-az04b_defconfig \
		${S}/configs/
	install -d ${S}/board/focalcrest/az04b
	install -m 0644 ${UNPACKDIR}/rk3588s-focalcrest-az04b.env \
		${S}/board/focalcrest/az04b/
}
