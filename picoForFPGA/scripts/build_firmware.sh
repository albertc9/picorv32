#!/bin/bash

# PicoSoC固件构建脚本
# ====================

set -e

echo "Building PicoSoC firmware..."

# 设置工具链路径
export PATH=$PWD/riscv-gnu-toolchain-riscv32i/bin:$PATH

# 检查工具链
if ! command -v riscv32-unknown-elf-gcc &> /dev/null; then
    echo "Error: RISC-V toolchain not found!"
    echo "Please make sure riscv-gnu-toolchain-riscv32i is properly installed."
    exit 1
fi

# 进入固件构建目录
cd firmware/build

# 清理之前的构建
echo "Cleaning previous build..."
make clean

# 构建固件
echo "Building firmware..."
make all

# 检查构建结果
if [ -f "firmware.hex" ]; then
    echo "Firmware build successful!"
    echo "Generated files:"
    ls -la firmware.*
else
    echo "Error: Firmware build failed!"
    exit 1
fi

echo "Build complete!" 