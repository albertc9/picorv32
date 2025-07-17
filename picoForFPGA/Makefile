# PicoRV32 主项目 Makefile
# ========================

# 默认目标
.PHONY: all clean help

all: help

# 帮助信息
help:
	@echo "PicoRV32 主项目 Makefile"
	@echo "========================"
	@echo ""
	@echo "可用目标:"
	@echo "  help          - 显示此帮助信息"
	@echo "  clean         - 清理生成的文件"
	@echo "  fpga          - 进入FPGA项目目录"
	@echo "  test          - 运行基本测试"
	@echo "  firmware      - 构建固件"
	@echo "  check-deps    - 检查依赖"
	@echo ""

# 进入FPGA项目
fpga:
	@echo "进入FPGA项目目录..."
	cd fpga && make help

# 运行测试
test:
	@echo "运行测试..."
	cd fpga && make test

# 构建固件
firmware:
	@echo "构建固件..."
	cd fpga && make firmware

# 检查依赖
check-deps:
	@echo "检查依赖..."
	cd fpga && make check-deps

# 清理
clean:
	@echo "清理生成的文件..."
	cd fpga && make clean
	rm -rf riscv-gnu-toolchain-riscv32i
	@echo "清理完成"

# 显示项目信息
info:
	@echo "项目信息:"
	@echo "  项目名称: PicoRV32"
	@echo "  FPGA项目目录: fpga/"
	@echo "  主要功能: RISC-V CPU核心"
	@echo "  支持平台: iCE40, Xilinx 7系列"
