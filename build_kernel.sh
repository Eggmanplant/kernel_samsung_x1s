#!/bin/bash

# Define o diretório base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
OUT_DIR="$SCRIPT_DIR/out"
mkdir -p "$OUT_DIR"

# Exporta as variáveis de ambiente para o Clang
export ARCH=arm64
export SUBARCH=arm64
export PATH="$SCRIPT_DIR/toolchain/clang-r416183b/bin:${PATH}"
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# 1. Mesclar os arquivos de configuração
echo "--- Mesclando Defconfigs ---"
scripts/kconfig/merge_config.sh -O "$OUT_DIR" \
    arch/arm64/configs/exynos9830_defconfig \
    arch/arm64/configs/r8s.config \
    arch/arm64/configs/ksu.config

# 2. Aplicar a configuração final
make O="$OUT_DIR" alldefconfig

# 3. GARANTIA: Forçar o Fake Uname 6.12 no .config gerado
# Isso evita que você tenha que editar o arquivo manualmente toda vez
sed -i 's/CONFIG_FAKE_UNAME_NONE=y/# CONFIG_FAKE_UNAME_NONE is not set/' "$OUT_DIR/.config"
echo "CONFIG_FAKE_UNAME=y" >> "$OUT_DIR/.config"
echo "CONFIG_FAKE_UNAME_6_12=y" >> "$OUT_DIR/.config"

# 4. Compilação
echo "--- Iniciando Compilação (j$(nproc)) ---"
make O="$OUT_DIR" --jobs=$(nproc)

# 5. Verificação do Binário
if [ -f "$OUT_DIR/arch/arm64/boot/Image.gz-dtb" ]; then
    echo "--- SUCESSO ---"
    echo "Kernel compilado em: $OUT_DIR/arch/arm64/boot/Image.gz-dtb"
    # Checar disfarce de versão no binário
    strings "$OUT_DIR/arch/arm64/boot/Image" | grep "6.12"
else
    echo "--- ERRO NA COMPILAÇÃO ---"
    exit 1
fi
