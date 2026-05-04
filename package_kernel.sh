#!/bin/bash
set -euo pipefail

cp arch/arm64/boot/Image AnyKernel3
cp anykernel.sh AnyKernel3

cd AnyKernel3
zip -r9 ../r8s-Kernel3.zip * -x .git README.md *placeholder
