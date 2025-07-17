# my_program Makefile
# 用于编译picoSoC C程序

# 工具链设置
RISCV_PREFIX ?= riscv32-unknown-elf-
CC = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy
SIZE = $(RISCV_PREFIX)size

# 编译选项
CFLAGS = -march=rv32i -mabi=ilp32 -O2 -Wall -Wextra
CFLAGS += -nostdlib -nostartfiles -ffreestanding
CFLAGS += -I../../lib

# 链接选项
LDFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles
LDFLAGS += -T../../linker/sections.lds

# 源文件
SOURCES = main.c
LIB_SOURCES = ../../lib/print.c
OBJECTS = $(SOURCES:.c=.o) $(LIB_SOURCES:.c=.o)

# 目标文件
TARGET = my_program
HEX_FILE = $(TARGET).hex

# 默认目标
all: $(HEX_FILE)

# 编译目标文件
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 链接生成可执行文件
$(TARGET): $(OBJECTS) ../../lib/start.S
	$(CC) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

# 生成HEX文件
$(HEX_FILE): $(TARGET)
	python3 ../../scripts/makehex.py $< 32768 > $@

# 清理
clean:
	rm -f *.o $(TARGET) $(HEX_FILE)

# 显示帮助
help:
	@echo "my_program Makefile"
	@echo "=================="
	@echo "可用目标:"
	@echo "  all     - 构建程序并生成HEX文件"
	@echo "  clean   - 清理生成的文件"
	@echo "  help    - 显示此帮助信息"
	@echo ""
	@echo "生成的文件:"
	@echo "  $(TARGET)     - 可执行文件"
	@echo "  $(HEX_FILE)   - HEX格式文件（用于FPGA）"

.PHONY: all clean help 