# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

require conf/machine/include/rk3566.inc
require conf/machine/include/focalcrest-common.inc

MACHINEOVERRIDES =. "focalcrest-rk3566:"

SERIAL_CONSOLES ?= "1500000;ttyS2"
