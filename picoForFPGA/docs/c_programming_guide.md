# picoSoC C程序开发指南

## 概述

本指南将帮助您在picoSoC上开发和运行C程序。picoSoC是一个基于PicoRV32 RISC-V CPU的完整SoC系统，支持C语言编程。

## 系统架构

### 内存映射

| 地址范围 | 描述 | 大小 |
|---------|------|------|
| 0x00000000 - 0x00000FFF | 内部SRAM | 4KB |
| 0x00100000 - 0x001FFFFF | SPI Flash | 1MB |
| 0x02000000 - 0x02000003 | SPI Flash配置寄存器 | 4字节 |
| 0x02000004 - 0x02000007 | UART时钟分频器 | 4字节 |
| 0x02000008 - 0x0200000B | UART数据寄存器 | 4字节 |
| 0x03000000 - 0xFFFFFFFF | 用户外设空间 | 保留 |

### 外设接口

#### UART控制器
- **数据寄存器**: 0x02000008
- **时钟分频器**: 0x02000004
- **波特率**: 115200 (默认)
- **数据格式**: 8N1

#### SPI Flash控制器
- **内存映射地址**: 0x00100000 - 0x001FFFFF
- **支持标准SPI Flash操作**
- **可用于程序存储和数据存储**

## 开发环境设置

### 1. 工具链要求

您需要RISC-V 32位工具链：
```bash
# 检查工具链是否可用
riscv32-unknown-elf-gcc --version
```

### 2. 项目结构

```
firmware/
├── examples/           # 示例程序
│   ├── hello/         # Hello World示例
│   ├── my_program/    # 您的自定义程序
│   └── ...
├── lib/               # 系统库
│   ├── start.S        # 启动代码
│   ├── system.h       # 系统头文件
│   └── print.c        # 打印函数实现
├── linker/            # 链接脚本
│   └── sections.lds   # 内存布局
└── build/             # 构建输出目录
```

## C程序开发

### 1. 基本程序结构

```c
#include "firmware.h"

// 主程序入口
void main(void) {
    // 初始化代码
    print_str("程序启动\n");
    
    // 主循环
    while (1) {
        // 您的程序逻辑
        print_str("Hello from picoSoC!\n");
        
        // 延时
        for (int i = 0; i < 1000000; i++) {
            __asm__ volatile ("nop");
        }
    }
}
```

### 2. 可用的系统函数

#### 打印函数
```c
void print_chr(char ch);           // 打印单个字符
void print_str(const char *p);     // 打印字符串
void print_dec(unsigned int val);  // 打印十进制数字
void print_hex(unsigned int val, int digits); // 打印十六进制数字
```

#### 示例用法
```c
print_str("计数器: ");
print_dec(42);
print_str("\n");

print_str("地址: 0x");
print_hex(0x12345678, 8);
print_str("\n");
```

### 3. 内存访问

#### 直接内存访问
```c
// 访问UART寄存器
volatile uint32_t *uart_data = (uint32_t*)0x02000008;
*uart_data = 'A';  // 发送字符'A'

// 访问Flash
volatile uint8_t *flash = (uint8_t*)0x00100000;
uint8_t data = flash[0];  // 读取Flash第一个字节
```

#### 外设寄存器定义
```c
#define UART_DATA    0x02000008
#define UART_CLKDIV  0x02000004
#define SPI_FLASH_CFG 0x02000000
```

### 4. 中断处理

```c
// 中断处理函数
uint32_t *irq(uint32_t *regs, uint32_t irqs) {
    // 处理中断
    if (irqs & 1) {
        // 处理外部中断0
        print_str("外部中断0触发\n");
    }
    
    return regs;
}
```

## 构建和运行

### 1. 使用构建脚本

```bash
# 进入项目目录
cd picoForFPGA

# 构建程序
./scripts/build_and_run.sh my_program
```

### 2. 手动构建

```bash
# 进入程序目录
cd firmware/examples/my_program

# 构建程序
make all

# 清理
make clean
```

### 3. 生成的文件

构建过程会生成以下文件：
- `my_program.elf`: ELF格式的可执行文件
- `my_program.hex`: HEX格式文件，用于加载到FPGA

## FPGA集成

### 1. 加载程序到FPGA

1. **生成比特流**: 在Vivado中综合picoSoC设计
2. **加载HEX文件**: 将生成的.hex文件写入FPGA的Flash
3. **配置FPGA**: 使用生成的比特流配置FPGA

### 2. UART连接

```bash
# 使用screen连接UART
screen /dev/ttyUSB0 115200

# 或使用minicom
minicom -D /dev/ttyUSB0 -b 115200

# 或使用picocom
picocom /dev/ttyUSB0 -b 115200
```

### 3. 调试技巧

#### 添加调试输出
```c
void debug_print(const char *msg) {
    print_str("[DEBUG] ");
    print_str(msg);
    print_str("\n");
}
```

#### 检查程序状态
```c
void print_status(void) {
    print_str("程序状态: ");
    print_str("运行中\n");
    print_str("内存使用: ");
    // 这里可以添加内存使用统计
}
```

## 高级功能

### 1. 使用Flash存储

```c
// 写入Flash
void write_flash(uint32_t addr, uint8_t data) {
    volatile uint8_t *flash = (uint8_t*)0x00100000;
    flash[addr] = data;
}

// 读取Flash
uint8_t read_flash(uint32_t addr) {
    volatile uint8_t *flash = (uint8_t*)0x00100000;
    return flash[addr];
}
```

### 2. 实现简单的文件系统

```c
// 简单的配置存储
struct config {
    uint32_t magic;
    uint32_t version;
    uint8_t data[100];
};

void save_config(struct config *cfg) {
    volatile struct config *flash_cfg = (struct config*)0x00100000;
    *flash_cfg = *cfg;
}

void load_config(struct config *cfg) {
    volatile struct config *flash_cfg = (struct config*)0x00100000;
    *cfg = *flash_cfg;
}
```

### 3. 实现命令行接口

```c
void process_command(const char *cmd) {
    if (strcmp(cmd, "help") == 0) {
        print_str("可用命令: help, status, reset\n");
    } else if (strcmp(cmd, "status") == 0) {
        print_str("系统状态: 正常\n");
    } else if (strcmp(cmd, "reset") == 0) {
        print_str("系统重启...\n");
        // 重启系统
    } else {
        print_str("未知命令: ");
        print_str(cmd);
        print_str("\n");
    }
}
```

## 常见问题

### 1. 程序不运行
- 检查HEX文件是否正确加载到Flash
- 确认FPGA配置正确
- 检查UART连接

### 2. 编译错误
- 确认RISC-V工具链已正确安装
- 检查头文件路径
- 确认链接脚本正确

### 3. 运行时错误
- 检查内存访问是否越界
- 确认外设地址正确
- 检查中断处理函数

## 示例程序

### 1. LED闪烁程序
```c
#include "firmware.h"

void main(void) {
    print_str("LED闪烁程序启动\n");
    
    int led_state = 0;
    while (1) {
        // 切换LED状态
        led_state = !led_state;
        
        if (led_state) {
            print_str("LED ON\n");
        } else {
            print_str("LED OFF\n");
        }
        
        // 延时
        for (int i = 0; i < 1000000; i++) {
            __asm__ volatile ("nop");
        }
    }
}
```

### 2. 温度传感器读取程序
```c
#include "firmware.h"

void main(void) {
    print_str("温度传感器程序启动\n");
    
    while (1) {
        // 读取温度传感器
        uint32_t temp_raw = *(volatile uint32_t*)0x03000000;
        uint32_t temp_celsius = temp_raw / 100;
        
        print_str("温度: ");
        print_dec(temp_celsius);
        print_str("°C\n");
        
        // 延时1秒
        for (int i = 0; i < 1000000; i++) {
            __asm__ volatile ("nop");
        }
    }
}
```

## 总结

通过本指南，您应该能够：
1. 理解picoSoC的系统架构
2. 编写基本的C程序
3. 构建和运行程序
4. 与FPGA硬件交互
5. 实现更复杂的功能

如果您有任何问题，请参考项目文档或联系开发团队。 