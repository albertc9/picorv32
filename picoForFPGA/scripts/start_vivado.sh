#!/bin/bash

# PicoSoC for FPGA - Vivado启动脚本
# =================================

echo "启动Vivado并创建PicoSoC项目..."

# 检查Vivado是否安装
if ! command -v vivado &> /dev/null; then
    echo "错误: 未找到Vivado!"
    echo "请确保Vivado已安装并在PATH中"
    echo "或者运行: source /path/to/vivado/settings64.sh"
    exit 1
fi

# 创建项目目录
mkdir -p vivado_project

# 启动Vivado并运行TCL脚本
echo "正在创建Vivado项目..."
vivado -mode batch -source scripts/create_vivado_project.tcl

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Vivado项目创建成功!"
    echo "项目位置: ./vivado_project/picosoc_fpga.xpr"
    echo ""
    echo "下一步操作:"
    echo "1. 打开Vivado GUI: vivado ./vivado_project/picosoc_fpga.xpr"
    echo "2. 或者直接运行: ./scripts/open_vivado_gui.sh"
    echo ""
    echo "项目文件已按正确顺序添加，可直接进行综合和实现。"
else
    echo "❌ Vivado项目创建失败!"
    exit 1
fi 