# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

COMPATIBLE_MACHINE:rk3576 = "rk3576"

RKBIN_BINDIR:rk3576 ?= "bin/rk35/"
RKBIN_BINVERS:rk3576 ?= "v1.09"
RKBIN_BINFILE:rk3576 ?= "rk3576_ddr_lp4_2112MHz_lp5_2736MHz_${RKBIN_BINVERS}.bin"
RKBIN_DEPLOY_FILENAME:rk3576 ?= "ddr-rk3576.bin"
