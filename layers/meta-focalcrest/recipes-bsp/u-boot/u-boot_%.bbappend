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
    if 'az07' not in d.getVar('MACHINEOVERRIDES').split(':'):
        return
    src = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), 'tee-rk3566.bin')
    dst = os.path.join(d.getVar('WORKDIR'), 'tee-optee-v1.bin')
    with open(src, 'rb') as f:
        blob = f.read()
    if blob[0:5] == b'OPTE\x01':
        bb.note("rkbin bl32 已是 OP-TEE v1 格式, 直接使用")
        payload = blob
    else:
        addr = int(d.getVar('FC_OPTEE_LOAD_ADDR'), 16)
        hdr = b'OPTE' + bytes([1]) + struct.pack('<H', 0) + bytes([2])
        hdr += struct.pack('<5I', len(blob), addr >> 32, addr & 0xffffffff, 0, 0)
        assert len(hdr) == 0x1c, len(hdr)
        payload = hdr + blob
        bb.note("已给 rkbin bl32 (%d bytes) 套 OP-TEE v1 头, load=0x%x"
                % (len(blob), addr))
    with open(dst, 'wb') as f:
        f.write(payload)
}
addtask fc_wrap_optee after do_configure before do_compile
do_fc_wrap_optee[depends] += "rockchip-rkbin-optee-os:do_deploy"

EXTRA_OEMAKE:append:az07 = " TEE=${WORKDIR}/tee-optee-v1.bin"

DEPENDS:append:az07 = " xxd-native"

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
