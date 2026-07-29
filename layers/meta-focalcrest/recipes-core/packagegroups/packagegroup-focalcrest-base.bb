# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

SUMMARY = "Focalcrest debug image package group"

inherit packagegroup

RDEPENDS:${PN} = "\
    ca-certificates \
    e2fsprogs-resize2fs \
    focalcrest-net-conf \
    focalcrest-usb-gadget \
    kmod \
    gptfdisk \
    e2fsprogs-mke2fs \
    libgpiod-tools \
    i2c-tools \
    mmc-utils \
    devmem2 \
    evtest \
    dtc \
    htop \
    iotop \
    sysstat \
    lsof \
    strace \
    trace-cmd \
    tcpdump \
    iperf3 \
    socat \
    rsync \
    tmux \
    python3 \
    file \
    fio \
    stress-ng \
    memtester \
"
