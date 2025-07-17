#!/bin/bash

# PicoSoC仿真脚本
# ===============

set -e

echo "Running PicoSoC simulation..."

# 检查Icarus Verilog
if ! command -v iverilog &> /dev/null; then
    echo "Error: Icarus Verilog not found!"
    echo "Please install Icarus Verilog: sudo apt-get install iverilog"
    exit 1
fi

# 编译测试平台
echo "Compiling testbench..."
iverilog -o sim.vvp \
    testbench/simple_tb.v \
    rtl/soc/picosoc.v \
    rtl/core/picorv32.v \
    rtl/peripheral/simpleuart.v \
    rtl/peripheral/spiflash.v

# 运行仿真
echo "Running simulation..."
vvp sim.vvp

# 检查波形文件
if [ -f "simple_tb.vcd" ]; then
    echo "Simulation completed successfully!"
    echo "Waveform file: simple_tb.vcd"
    echo "You can view the waveform with: gtkwave simple_tb.vcd"
else
    echo "Error: Simulation failed!"
    exit 1
fi

echo "Simulation complete!" 