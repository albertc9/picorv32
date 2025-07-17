#!/bin/bash

# picoSoC C程序构建和运行脚本
# ================================

set -e

echo "=== picoSoC C程序构建和运行脚本 ==="
echo ""

# 检查参数
if [ $# -eq 0 ]; then
    echo "用法: $0 <程序目录>"
    echo "示例: $0 examples/my_program"
    echo ""
    echo "可用的程序目录:"
    ls -d firmware/examples/*/ 2>/dev/null | sed 's|firmware/examples/||' | sed 's|/||' || echo "  无可用程序"
    exit 1
fi

PROGRAM_DIR="firmware/examples/$1"

# 检查程序目录是否存在
if [ ! -d "$PROGRAM_DIR" ]; then
    echo "错误: 程序目录 '$PROGRAM_DIR' 不存在"
    exit 1
fi

echo "构建程序: $1"
echo "程序目录: $PROGRAM_DIR"
echo ""

# 检查工具链
echo "检查RISC-V工具链..."
if ! command -v riscv32-unknown-elf-gcc &> /dev/null; then
    echo "警告: RISC-V工具链未找到"
    echo "请确保已安装RISC-V工具链或使用项目内置的工具链"
    echo ""
    echo "尝试使用项目内置工具链..."
    export PATH=$PWD/riscv-gnu-toolchain-riscv32i/bin:$PATH
    
    if ! command -v riscv32-unknown-elf-gcc &> /dev/null; then
        echo "错误: 无法找到RISC-V工具链"
        echo "请先构建工具链或安装系统工具链"
        exit 1
    fi
fi

echo "工具链检查通过: $(which riscv32-unknown-elf-gcc)"
echo ""

# 进入程序目录
cd "$PROGRAM_DIR"

# 检查Makefile
if [ ! -f "Makefile" ]; then
    echo "错误: 程序目录中没有Makefile"
    exit 1
fi

# 清理之前的构建
echo "清理之前的构建..."
make clean 2>/dev/null || true

# 构建程序
echo "构建程序..."
make all

# 检查构建结果
if [ -f "*.hex" ]; then
    HEX_FILE=$(ls *.hex)
    echo ""
    echo "构建成功!"
    echo "生成的文件:"
    ls -la *.hex *.elf 2>/dev/null || ls -la *.hex 2>/dev/null
    echo ""
    echo "=== 程序信息 ==="
    echo "HEX文件: $HEX_FILE"
    echo "文件大小: $(stat -c%s $HEX_FILE) 字节"
    echo ""
    echo "=== 下一步操作 ==="
    echo "1. 将 $HEX_FILE 文件加载到FPGA的Flash中"
    echo "2. 配置FPGA使用picoSoC设计"
    echo "3. 通过UART连接查看程序输出"
    echo ""
    echo "UART连接信息:"
    echo "  波特率: 115200"
    echo "  数据位: 8"
    echo "  停止位: 1"
    echo "  无校验位"
    echo ""
    echo "示例UART连接命令:"
    echo "  screen /dev/ttyUSB0 115200"
    echo "  或"
    echo "  minicom -D /dev/ttyUSB0 -b 115200"
else
    echo "错误: 构建失败，未生成HEX文件"
    exit 1
fi

echo "构建和运行脚本完成!" 