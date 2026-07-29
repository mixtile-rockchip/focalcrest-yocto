# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

SUMMARY = "Focalcrest board bring-up debug image"

LICENSE = "MIT"

inherit core-image

CORE_IMAGE_EXTRA_INSTALL += "\
    packagegroup-focalcrest-base \
    kernel-modules \
"

IMAGE_FEATURES += "\
    ssh-server-openssh \
    allow-empty-password \
    allow-root-login \
    empty-root-password \
    serial-autologin-root \
    post-install-logging \
    tools-debug \
"

IMAGE_ROOTFS_EXTRA_SPACE = "65536"
