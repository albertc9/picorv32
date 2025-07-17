# PicoRV32 通用固件构建系统
# 支持多种FPGA平台的通用编译和下载流程

# 包含配置文件
-include config.mk

# 默认配置
PLATFORM ?= ice40
BOARD ?= icebreaker
TOOLCHAIN_PREFIX ?= riscv32-unknown-elf-
EXAMPLE ?= hello

# 编译选项
CFLAGS ?= -Os -march=rv32imc -mabi=ilp32 -ffreestanding -nostdlib -Wall -Wextra
LDFLAGS ?= -Wl,--build-id=none,-Bstatic,--strip-debug

# 目录定义
CORE_DIR = core
LINKER_DIR = linker
EXAMPLES_DIR = examples
PLATFORMS_DIR = platforms
SCRIPTS_DIR = scripts
BUILD_DIR = build
BUILD_EXAMPLE_DIR = $(BUILD_DIR)/$(EXAMPLE)

# 平台特定配置
PLATFORM_CONFIG = $(PLATFORMS_DIR)/$(PLATFORM)/config.mk
-include $(PLATFORM_CONFIG)

# 核心源文件
CORE_SOURCES = $(CORE_DIR)/start.S \
               $(CORE_DIR)/uart.c \
               $(CORE_DIR)/gpio.c \
               $(CORE_DIR)/flash.c \
               $(CORE_DIR)/libc/string.c \
               $(CORE_DIR)/libc/stdio.c

# 核心目标文件
CORE_OBJECTS = $(CORE_SOURCES:%.c=$(BUILD_DIR)/%.o)
CORE_OBJECTS := $(CORE_OBJECTS:%.S=$(BUILD_DIR)/%.o)

# 示例源文件
EXAMPLE_SOURCE = $(EXAMPLES_DIR)/$(EXAMPLE)/main.c
EXAMPLE_OBJECT = $(BUILD_EXAMPLE_DIR)/main.o

# 链接脚本
LINKER_SCRIPT = $(LINKER_DIR)/platforms/$(PLATFORM)/$(BOARD).lds

# 输出文件
ELF_FILE = $(BUILD_EXAMPLE_DIR)/$(EXAMPLE).elf
BIN_FILE = $(BUILD_EXAMPLE_DIR)/$(EXAMPLE).bin
HEX_FILE = $(BUILD_EXAMPLE_DIR)/$(EXAMPLE).hex
MAP_FILE = $(BUILD_EXAMPLE_DIR)/$(EXAMPLE).map

# 默认目标
.PHONY: all help build flash clean monitor debug sim

all: help

help:
	@echo "PicoRV32 通用固件构建系统"
	@echo ""
	@echo "用法:"
	@echo "  make build example=<程序名>    # 编译程序"
	@echo "  make flash example=<程序名>    # 下载到FPGA"
	@echo "  make monitor                  # 启动串口监视器"
	@echo "  make clean                    # 清理构建文件"
	@echo "  make debug example=<程序名>   # 调试模式编译"
	@echo "  make sim example=<程序名>     # 仿真模式"
	@echo ""
	@echo "示例:"
	@echo "  make build example=hello"
	@echo "  make flash example=blink"
	@echo "  make build example=uart_test"
	@echo ""
	@echo "可用示例:"
	@ls $(EXAMPLES_DIR) | sed 's/^/  /'

# 构建目标
build: $(ELF_FILE) $(BIN_FILE) $(HEX_FILE)

$(ELF_FILE): $(CORE_OBJECTS) $(EXAMPLE_OBJECT) $(LINKER_SCRIPT)
	@echo "链接 $(EXAMPLE).elf..."
	@mkdir -p $(BUILD_EXAMPLE_DIR)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) $(LDFLAGS) \
		-T $(LINKER_SCRIPT) \
		-o $@ \
		$(CORE_OBJECTS) $(EXAMPLE_OBJECT) \
		-Wl,-Map,$(MAP_FILE)

$(BIN_FILE): $(ELF_FILE)
	@echo "生成 $(EXAMPLE).bin..."
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

$(HEX_FILE): $(BIN_FILE)
	@echo "生成 $(EXAMPLE).hex..."
	$(SCRIPTS_DIR)/bin2hex.py $< $@

# 编译核心库文件
$(BUILD_DIR)/%.o: %.c
	@echo "编译 $<..."
	@mkdir -p $(dir $@)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.S
	@echo "汇编 $<..."
	@mkdir -p $(dir $@)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c -o $@ $<

# 编译示例文件
$(EXAMPLE_OBJECT): $(EXAMPLE_SOURCE)
	@echo "编译示例 $<..."
	@mkdir -p $(BUILD_EXAMPLE_DIR)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c -o $@ $<

# 下载目标
flash: $(BIN_FILE)
	@echo "下载 $(EXAMPLE) 到 $(PLATFORM)/$(BOARD)..."
	$(SCRIPTS_DIR)/flash.sh $(PLATFORM) $(BOARD) $(BIN_FILE)

# 调试模式
debug: CFLAGS += -g -DDEBUG
debug: build

# 仿真模式
sim: $(ELF_FILE)
	@echo "启动仿真..."
	$(SCRIPTS_DIR)/sim.sh $(PLATFORM) $(BOARD) $(ELF_FILE)

# 串口监视器
monitor:
	@echo "启动串口监视器..."
	$(SCRIPTS_DIR)/monitor.sh $(PLATFORM) $(BOARD)

# 清理
clean:
	@echo "清理构建文件..."
	rm -rf $(BUILD_DIR)

# 安装依赖
install-deps:
	@echo "检查依赖..."
	@which $(TOOLCHAIN_PREFIX)gcc > /dev/null || (echo "错误: RISC-V工具链未找到"; exit 1)
	@which yosys > /dev/null || (echo "警告: Yosys未安装")
	@which nextpnr-ice40 > /dev/null || (echo "警告: nextpnr-ice40未安装")
	@which iceprog > /dev/null || (echo "警告: iceprog未安装")

# 列出可用示例
list-examples:
	@echo "可用示例:"
	@ls $(EXAMPLES_DIR) | sed 's/^/  /'

# 列出可用平台
list-platforms:
	@echo "可用平台:"
	@ls $(PLATFORMS_DIR) | sed 's/^/  /'

# 检查配置
check-config:
	@echo "当前配置:"
	@echo "  平台: $(PLATFORM)"
	@echo "  板卡: $(BOARD)"
	@echo "  工具链: $(TOOLCHAIN_PREFIX)"
	@echo "  示例: $(EXAMPLE)"
	@echo "  编译选项: $(CFLAGS)" 