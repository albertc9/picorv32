# PicoRV32 固件系统配置文件
# 复制此文件并根据您的需求修改

# ============================================================================
# 平台配置
# ============================================================================

# 目标平台 (ice40, xilinx, generic)
PLATFORM = xilinx

# 具体板卡
# iCE40系列: icebreaker, hx8k, up5k
# Xilinx系列: arty, basys3, zybo
# 通用平台: generic
BOARD = arty

# ============================================================================
# 工具链配置
# ============================================================================

# RISC-V工具链前缀
TOOLCHAIN_PREFIX = riscv32-unknown-elf-

# 编译选项
CFLAGS = -Os -march=rv32imczicsr -mabi=ilp32 -ffreestanding -nostdlib -Wall -Wextra

# 链接选项
LDFLAGS = -Wl,--build-id=none,-Bstatic,--strip-debug

# ============================================================================
# 硬件配置
# ============================================================================

# 系统时钟频率 (Hz)
SYSTEM_CLOCK = 12000000

# UART波特率
UART_BAUDRATE = 115200

# SRAM大小 (字节)
SRAM_SIZE = 65536

# Flash大小 (字节)
FLASH_SIZE = 1048576

# ============================================================================
# 调试配置
# ============================================================================

# 启用调试信息
DEBUG = 0

# 启用优化
OPTIMIZE = 1

# 启用警告
WARNINGS = 1

# ============================================================================
# 平台特定配置
# ============================================================================

# iCE40系列配置
ifeq ($(PLATFORM),ice40)
    # iCEBreaker板配置
    ifeq ($(BOARD),icebreaker)
        SYSTEM_CLOCK = 12000000
        UART_BAUDRATE = 115200
        SRAM_SIZE = 131072  # 128KB
        FLASH_SIZE = 1048576 # 1MB
    endif
    
    # HX8K板配置
    ifeq ($(BOARD),hx8k)
        SYSTEM_CLOCK = 12000000
        UART_BAUDRATE = 115200
        SRAM_SIZE = 2048    # 2KB
        FLASH_SIZE = 1048576 # 1MB
    endif
    
    # UP5K板配置
    ifeq ($(BOARD),up5k)
        SYSTEM_CLOCK = 12000000
        UART_BAUDRATE = 115200
        SRAM_SIZE = 65536   # 64KB
        FLASH_SIZE = 1048576 # 1MB
    endif
endif

# Xilinx系列配置
ifeq ($(PLATFORM),xilinx)
    # Arty A7板配置
    ifeq ($(BOARD),arty)
        SYSTEM_CLOCK = 100000000
        UART_BAUDRATE = 115200
        SRAM_SIZE = 131072  # 128KB
        FLASH_SIZE = 16777216 # 16MB
    endif
    
    # Basys3板配置
    ifeq ($(BOARD),basys3)
        SYSTEM_CLOCK = 100000000
        UART_BAUDRATE = 115200
        SRAM_SIZE = 131072  # 128KB
        FLASH_SIZE = 16777216 # 16MB
    endif
endif

# 通用平台配置
ifeq ($(PLATFORM),generic)
    SYSTEM_CLOCK = 50000000
    UART_BAUDRATE = 115200
    SRAM_SIZE = 65536   # 64KB
    FLASH_SIZE = 1048576 # 1MB
endif

# ============================================================================
# 编译选项调整
# ============================================================================

# 调试模式
ifneq ($(DEBUG),0)
    CFLAGS += -g -DDEBUG
    OPTIMIZE = 0
endif

# 优化级别
ifeq ($(OPTIMIZE),1)
    CFLAGS += -Os
else
    CFLAGS += -O0
endif

# 警告级别
ifeq ($(WARNINGS),1)
    CFLAGS += -Wall -Wextra -Werror
else
    CFLAGS += -w
endif

# 添加系统定义
CFLAGS += -DSYSTEM_CLOCK_CONFIG=$(SYSTEM_CLOCK)
CFLAGS += -DUART_BAUDRATE_CONFIG=$(UART_BAUDRATE)
CFLAGS += -DSRAM_SIZE_CONFIG=$(SRAM_SIZE)
CFLAGS += -DFLASH_SIZE_CONFIG=$(FLASH_SIZE) 