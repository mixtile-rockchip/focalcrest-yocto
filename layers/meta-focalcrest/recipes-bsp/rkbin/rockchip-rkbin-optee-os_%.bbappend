# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Focalcrest

COMPATIBLE_MACHINE:rk3576 = "rk3576"

RKBIN_BINDIR:rk3576 ?= "bin/rk35/"
RKBIN_BINVERS:rk3576 ?= "v1.05"
RKBIN_BINFILE:rk3576 ?= "rk3576_bl32_${RKBIN_BINVERS}.bin"
RKBIN_DEPLOY_FILENAME:rk3576 ?= "tee-rk3576.bin"
