#!/bin/bash
# Focalcrest Yocto BSP environment setup
#   usage:  . ./setup-env.sh [build directory]
# Default build directory: build-az07
FC_ROOT=$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)
export BITBAKEDIR="$FC_ROOT/layers/bitbake"
export TEMPLATECONF="$FC_ROOT/layers/meta-focalcrest/conf/templates/focalcrest"
. "$FC_ROOT/layers/openembedded-core/oe-init-build-env" "${1:-$FC_ROOT/build-az07}"
