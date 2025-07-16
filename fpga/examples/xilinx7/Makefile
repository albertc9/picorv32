# Xilinx FPGA 项目 Makefile
# =========================

# 配置变量
PROJECT_NAME = picorv32_xilinx
TOP_MODULE = artix7_demo
DEVICE = xc7a35t-csg324-1
VIVADO = vivado
VIVADO_BATCH = $(VIVADO) -mode batch -source

# 源文件目录
RTL_DIR = ../../rtl
CONSTRAINTS_DIR = ../../constraints
SCRIPTS_DIR = ../../scripts

# 默认目标
.PHONY: all clean help synth impl bitstream program

all: help

# 帮助信息
help:
	@echo "Xilinx FPGA 项目 Makefile"
	@echo "========================="
	@echo ""
	@echo "可用目标:"
	@echo "  help          - 显示此帮助信息"
	@echo "  clean         - 清理生成的文件"
	@echo "  synth         - 运行综合"
	@echo "  impl          - 运行实现"
	@echo "  bitstream     - 生成比特流"
	@echo "  program       - 编程FPGA"
	@echo "  all-steps     - 运行完整流程"
	@echo ""

# 清理
clean:
	@echo "清理生成的文件..."
	rm -rf $(PROJECT_NAME).xpr
	rm -rf $(PROJECT_NAME).cache
	rm -rf $(PROJECT_NAME).hw
	rm -rf $(PROJECT_NAME).ip_user_files
	rm -rf $(PROJECT_NAME).runs
	rm -rf $(PROJECT_NAME).sim
	rm -rf *.bit
	rm -rf *.ltx
	rm -rf *.rpt
	rm -rf *.log
	@echo "清理完成"

# 综合
synth:
	@echo "运行综合..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/synthesis/xilinx_synth.tcl
	@echo "综合完成"

# 实现
impl: synth
	@echo "运行实现..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/synthesis/xilinx_impl.tcl
	@echo "实现完成"

# 生成比特流
bitstream: impl
	@echo "生成比特流..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/synthesis/xilinx_bitstream.tcl
	@echo "比特流生成完成"

# 编程FPGA
program: bitstream
	@echo "编程FPGA..."
	$(VIVADO_BATCH) $(SCRIPTS_DIR)/programming/xilinx_program.tcl
	@echo "编程完成"

# 完整流程
all-steps: clean bitstream
	@echo "完整流程执行完成"

# 检查工具
check-vivado:
	@which $(VIVADO) > /dev/null || (echo "错误: Vivado 未找到" && exit 1)
	@echo "Vivado 工具检查通过"

# 显示项目信息
info:
	@echo "项目信息:"
	@echo "  项目名称: $(PROJECT_NAME)"
	@echo "  顶层模块: $(TOP_MODULE)"
	@echo "  目标器件: $(DEVICE)"
	@echo "  Vivado: $(shell which $(VIVADO) 2>/dev/null || echo '未找到')" 