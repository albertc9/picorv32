# PicoRV32 FPGA Project Makefile
# ================================

# 配置变量
PROJECT_NAME = picorv32-fpga
RTL_DIR = rtl
SIMULATION_DIR = simulation
EXAMPLES_DIR = examples
SCRIPTS_DIR = scripts

# 工具链配置
IVERILOG = iverilog
VVP = vvp
YOSYS = yosys
NEXTPNR = nextpnr-ice40
ICEPACK = icepack
ICEPROG = iceprog

# 默认目标
.PHONY: all clean help

all: help

# 帮助信息
help:
	@echo "PicoRV32 FPGA Project Makefile"
	@echo "================================"
	@echo ""
	@echo "可用目标:"
	@echo "  help          - 显示此帮助信息"
	@echo "  clean         - 清理生成的文件"
	@echo "  test          - 运行基本测试"
	@echo "  test-ez       - 运行简单测试"
	@echo "  sim           - 运行仿真"
	@echo "  synth-ice40   - 为iCE40 FPGA综合"
	@echo "  synth-xilinx  - 为Xilinx FPGA综合"
	@echo "  prog-ice40    - 编程iCE40 FPGA"
	@echo "  firmware      - 构建固件"
	@echo ""

# 清理
clean:
	@echo "清理生成的文件..."
	rm -rf *.vcd *.vvp *.bin *.hex *.elf *.map *.o
	rm -rf $(EXAMPLES_DIR)/*/build
	rm -rf $(SIMULATION_DIR)/*.vcd
	@echo "清理完成"

# 基本测试
test:
	@echo "运行基本测试..."
	cd $(SIMULATION_DIR) && $(IVERILOG) -o testbench.vvp testbench.v ../$(RTL_DIR)/core/picorv32.v
	cd $(SIMULATION_DIR) && $(VVP) testbench.vvp

# 简单测试
test-ez:
	@echo "运行简单测试..."
	cd $(SIMULATION_DIR) && $(IVERILOG) -o testbench_ez.vvp testbench_ez.v ../$(RTL_DIR)/core/picorv32.v
	cd $(SIMULATION_DIR) && $(VVP) testbench_ez.vvp

# 仿真
sim: test
	@echo "仿真完成"

# 为iCE40 FPGA综合
synth-ice40:
	@echo "为iCE40 FPGA综合..."
	@echo "请进入具体示例目录运行综合"

# 为Xilinx FPGA综合
synth-xilinx:
	@echo "为Xilinx FPGA综合..."
	@echo "请进入具体示例目录运行综合"

# 编程iCE40 FPGA
prog-ice40:
	@echo "编程iCE40 FPGA..."
	@echo "请进入具体示例目录运行编程"

# 构建固件
firmware:
	@echo "构建固件..."
	cd firmware && make clean && make

# 显示项目结构
tree:
	@echo "项目结构:"
	@tree -I '*.git|*.vvp|*.vcd|*.bin|*.hex|*.elf|*.map|*.o|build'

# 检查依赖
check-deps:
	@echo "检查工具依赖..."
	@which $(IVERILOG) > /dev/null || echo "警告: iverilog 未找到"
	@which $(VVP) > /dev/null || echo "警告: vvp 未找到"
	@which $(YOSYS) > /dev/null || echo "警告: yosys 未找到"
	@which $(NEXTPNR) > /dev/null || echo "警告: nextpnr-ice40 未找到"
	@which $(ICEPACK) > /dev/null || echo "警告: icepack 未找到"
	@which $(ICEPROG) > /dev/null || echo "警告: iceprog 未找到" 