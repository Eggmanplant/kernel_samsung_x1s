#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export ARCH=arm64
export PATH="$SCRIPT_DIR/toolchain/clang-r416183b/bin:${PATH}"
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-

scripts/kconfig/merge_config.sh -m -O . arch/arm64/configs/exynos9830_defconfig arch/arm64/configs/r8s.config arch/arm64/configs/ksu.config
make KCONFIG_ALLCONFIG=.config alldefconfig
make --jobs=$(nproc)
