# PicoRV32 通用固件系统

这是一个通用的PicoRV32固件编译和下载系统，支持多种FPGA平台。

## 目录结构

```
firmware/
├── README.md              # 本文档
├── Makefile               # 主Makefile
├── config.mk              # 配置文件
├── scripts/               # 构建脚本
│   ├── build.sh           # 通用构建脚本
│   ├── flash.sh           # 通用下载脚本
│   └── clean.sh           # 清理脚本
├── core/                  # 核心库文件
│   ├── start.S            # 启动代码
│   ├── system.h           # 系统定义
│   ├── uart.c             # UART驱动
│   ├── uart.h             # UART头文件
│   ├── gpio.c             # GPIO驱动
│   ├── gpio.h             # GPIO头文件
│   ├── flash.c            # Flash驱动
│   ├── flash.h            # Flash头文件
│   └── libc/              # 简化C库
├── linker/                # 链接脚本
│   ├── sections.lds       # 通用链接脚本
│   └── platforms/         # 平台特定链接脚本
├── examples/              # 示例程序
│   ├── hello/             # Hello World示例
│   ├── blink/             # LED闪烁示例
│   └── uart_test/         # UART测试示例
└── platforms/             # 平台支持
    ├── ice40/             # iCE40系列支持
    ├── xilinx/            # Xilinx系列支持
    └── generic/           # 通用平台支持
```

## 快速开始

### 1. 配置目标平台

编辑 `config.mk` 文件，设置您的目标平台：

```makefile
# 目标平台 (ice40, xilinx, generic)
PLATFORM = ice40

# 具体板卡 (icebreaker, hx8k, arty, etc.)
BOARD = icebreaker

# 工具链前缀
TOOLCHAIN_PREFIX = riscv32-unknown-elf-

# 编译选项
CFLAGS = -Os -march=rv32imc -mabi=ilp32
```

### 2. 编译示例程序

```bash
# 编译Hello World示例
make example=hello

# 编译LED闪烁示例
make example=blink

# 编译自定义程序
make example=my_program
```

### 3. 下载到FPGA

```bash
# 下载固件到FPGA
make flash example=hello

# 或者分步执行
make build example=hello
make flash example=hello
```

### 4. 运行和调试

```bash
# 启动串口监视器
make monitor

# 清理构建文件
make clean
```

## 支持的平台

### iCE40系列
- **iCEBreaker**: `PLATFORM=ice40 BOARD=icebreaker`
- **HX8K**: `PLATFORM=ice40 BOARD=hx8k`
- **UP5K**: `PLATFORM=ice40 BOARD=up5k`

### Xilinx系列
- **Arty A7**: `PLATFORM=xilinx BOARD=arty`
- **Basys3**: `PLATFORM=xilinx BOARD=basys3`
- **Zybo**: `PLATFORM=xilinx BOARD=zybo`

### 通用平台
- **Generic**: `PLATFORM=generic BOARD=generic`

## 内存映射

### 标准内存映射
```
0x00000000 - 0x0000FFFF: 内部SRAM (64KB)
0x00100000 - 0x001FFFFF: 程序Flash (1MB)
0x02000000 - 0x02000003: UART控制寄存器
0x02000004 - 0x02000007: UART数据寄存器
0x02000008 - 0x0200000B: GPIO控制寄存器
0x0200000C - 0x0200000F: GPIO数据寄存器
0x03000000 - 0x03FFFFFF: 外部设备空间
```

## 开发指南

### 创建新程序

1. 在 `examples/` 目录下创建新文件夹
2. 创建 `main.c` 文件
3. 可选：创建 `Makefile` 进行自定义配置

### 添加新平台支持

1. 在 `platforms/` 目录下创建平台文件夹
2. 创建平台特定的链接脚本
3. 添加平台特定的下载脚本
4. 更新主Makefile

### 使用系统库

```c
#include "system.h"
#include "uart.h"
#include "gpio.h"

int main() {
    uart_init(115200);
    gpio_init();
    
    uart_puts("Hello, PicoRV32!\n");
    gpio_set_led(1);
    
    return 0;
}
```

## 故障排除

### 常见问题

1. **工具链未找到**: 确保RISC-V工具链已安装并正确设置PATH
2. **下载失败**: 检查USB连接和板卡电源
3. **串口无输出**: 检查波特率设置和串口设备

### 调试技巧

1. 使用 `make debug` 启用调试信息
2. 使用 `make sim` 进行仿真测试
3. 检查生成的 `.map` 文件了解内存布局

## 许可证

本项目遵循与PicoRV32相同的ISC许可证。 