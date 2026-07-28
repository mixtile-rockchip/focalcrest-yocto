# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

require recipes-bsp/u-boot/u-boot-common.inc
require recipes-bsp/u-boot/u-boot.inc

DEPENDS += "bc-native dtc-native gnutls-native python3-pyelftools-native"

SRCREV = "ece349ade2973e220f524ce59e59711cc919263f"
