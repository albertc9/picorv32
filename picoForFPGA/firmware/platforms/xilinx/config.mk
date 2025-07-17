# Xilinx平台配置文件
# 适用于Arty A7, Basys3等A7系列FPGA

# ============================================================================
# Xilinx工具链配置
# ============================================================================

# Vivado工具路径 (如果不在PATH中)
VIVADO_PATH ?= /opt/Xilinx/Vivado/2023.2/bin

# 工具链前缀
TOOLCHAIN_PREFIX = riscv32-unknown-elf-

# ============================================================================
# 编译选项
# ============================================================================

# A7系列特定的编译选项
CFLAGS += -DXILINX_A7
CFLAGS += -DUSE_BRAM
CFLAGS += -DUSE_SPI_FLASH

# 优化选项
CFLAGS += -O2 -fomit-frame-pointer

# ============================================================================
# 硬件特定配置
# ============================================================================

# Arty A7-35T配置
ifeq ($(BOARD),arty)
    # 系统时钟 (100MHz)
    SYSTEM_CLOCK = 100000000
    
    # UART波特率
    UART_BAUDRATE = 115200
    
    # BRAM大小 (128KB)
    SRAM_SIZE = 131072
    
    # SPI Flash大小 (16MB)
    FLASH_SIZE = 16777216
    
    # 板卡特定定义
    CFLAGS += -DARTY_A7
    CFLAGS += -DLED_COUNT=4
    CFLAGS += -DBTN_COUNT=4
endif

# Basys3配置
ifeq ($(BOARD),basys3)
    # 系统时钟 (100MHz)
    SYSTEM_CLOCK = 100000000
    
    # UART波特率
    UART_BAUDRATE = 115200
    
    # BRAM大小 (128KB)
    SRAM_SIZE = 131072
    
    # SPI Flash大小 (16MB)
    FLASH_SIZE = 16777216
    
    # 板卡特定定义
    CFLAGS += -DBASYS3
    CFLAGS += -DLED_COUNT=16
    CFLAGS += -DBTN_COUNT=5
endif

# ============================================================================
# 下载配置
# ============================================================================

# 下载工具
FLASH_TOOL = vivado
FLASH_SCRIPT = $(SCRIPTS_DIR)/xilinx_flash.tcl

# 串口设备检测
UART_DEVICE ?= /dev/ttyUSB0

# ============================================================================
# 调试配置
# ============================================================================

# 启用调试支持
DEBUG_SUPPORT = 1

# 调试端口
DEBUG_PORT = 3333

# ============================================================================
# 构建目标
# ============================================================================

# 生成bitstream的目标
.PHONY: bitstream
bitstream:
	@echo "生成bitstream需要Vivado项目文件"
	@echo "请使用Vivado创建项目并生成bitstream"

# 下载bitstream
.PHONY: download-bitstream
download-bitstream:
	@echo "下载bitstream到FPGA..."
	@if [ -f $(BITSTREAM_FILE) ]; then \
		$(VIVADO_PATH)/vivado -mode batch -source $(FLASH_SCRIPT) -tclargs $(BITSTREAM_FILE); \
	else \
		echo "错误: bitstream文件不存在"; \
		exit 1; \
	fi 