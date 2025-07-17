# PicoRV32 固件系统使用指南

## 快速开始

### 1. 环境准备

确保已安装以下工具：
- RISC-V GNU工具链 (`riscv32-unknown-elf-gcc`)
- Make工具
- Python 3 (用于脚本)

### 2. 配置目标平台

编辑 `config.mk` 文件，设置您的目标平台：

```makefile
# 目标平台 (ice40, xilinx, generic)
PLATFORM = ice40

# 具体板卡 (icebreaker, hx8k, arty, etc.)
BOARD = icebreaker

# 工具链前缀
TOOLCHAIN_PREFIX = riscv32-unknown-elf-
```

### 3. 编译示例程序

```bash
# 编译Hello World示例
make build example=hello

# 编译LED闪烁示例
make build example=blink

# 编译UART测试示例
make build example=uart_test
```

### 4. 下载到FPGA

```bash
# 下载Hello World示例到iCEBreaker板
make flash example=hello

# 下载LED闪烁示例到HX8K板
make flash example=blink
```

### 5. 运行和调试

```bash
# 启动串口监视器
make monitor

# 或者手动启动
./scripts/monitor.sh -d /dev/ttyUSB0 -b 115200
```

## 详细使用说明

### 编译流程

1. **编译核心库**: 系统自动编译 `core/` 目录下的所有源文件
2. **编译示例程序**: 编译 `examples/<程序名>/main.c`
3. **链接**: 使用平台特定的链接脚本生成ELF文件
4. **生成二进制文件**: 从ELF文件生成 `.bin` 和 `.hex` 文件

### 目录结构说明

```
firmware/
├── core/           # 核心库文件
│   ├── start.S     # 启动代码
│   ├── system.h    # 系统定义
│   ├── uart.c/h    # UART驱动
│   ├── gpio.c/h    # GPIO驱动
│   └── libc/       # 简化C库
├── examples/       # 示例程序
│   ├── hello/      # Hello World示例
│   ├── blink/      # LED闪烁示例
│   └── uart_test/  # UART测试示例
├── linker/         # 链接脚本
│   └── platforms/  # 平台特定链接脚本
└── scripts/        # 构建和下载脚本
```

### 创建新程序

1. 在 `examples/` 目录下创建新文件夹
2. 创建 `main.c` 文件
3. 使用系统库函数

示例：
```c
#include "system.h"
#include "uart.h"
#include "gpio.h"

int main() {
    // 初始化系统
    system_init();
    
    // 初始化UART
    uart_init(115200);
    
    // 初始化GPIO
    gpio_init();
    
    // 配置LED为输出
    gpio_config_t led_config = {
        .direction = GPIO_DIR_OUTPUT,
        .pull = GPIO_PULL_NONE,
        .irq_trigger = GPIO_IRQ_NONE,
        .irq_enable = false
    };
    gpio_config(0, &led_config);
    
    // 主循环
    while (1) {
        uart_puts("Hello, PicoRV32!\n");
        gpio_toggle(0);
        delay_ms(1000);
    }
    
    return 0;
}
```

4. 编译和下载：
```bash
make build example=my_program
make flash example=my_program
```

### 支持的平台

#### iCE40系列
- **iCEBreaker**: `PLATFORM=ice40 BOARD=icebreaker`
- **HX8K**: `PLATFORM=ice40 BOARD=hx8k`
- **UP5K**: `PLATFORM=ice40 BOARD=up5k`

#### Xilinx系列
- **Arty A7**: `PLATFORM=xilinx BOARD=arty`
- **Basys3**: `PLATFORM=xilinx BOARD=basys3`

#### 通用平台
- **Generic**: `PLATFORM=generic BOARD=generic`

### 内存映射

```
0x00000000 - 0x0000FFFF: 内部SRAM (64KB)
0x00100000 - 0x001FFFFF: 程序Flash (1MB)
0x02000000 - 0x02000003: UART控制寄存器
0x02000004 - 0x02000007: UART数据寄存器
0x02000008 - 0x0200000B: GPIO控制寄存器
0x0200000C - 0x0200000F: GPIO数据寄存器
0x03000000 - 0x03FFFFFF: 外部设备空间
```

### 系统库函数

#### UART函数
```c
uart_init(baudrate);           // 初始化UART
uart_putc(c);                  // 发送字符
uart_puts(str);                // 发送字符串
uart_printf(fmt, ...);         // 格式化输出
uart_getc(&c);                 // 接收字符
uart_available();              // 检查是否有数据
```

#### GPIO函数
```c
gpio_init();                   // 初始化GPIO
gpio_config(pin, &config);     // 配置GPIO
gpio_write(pin, value);        // 写入GPIO
gpio_read(pin, &value);        // 读取GPIO
gpio_toggle(pin);              // 切换GPIO
gpio_set_led(led, state);      // 设置LED
```

#### 系统函数
```c
system_init();                 // 系统初始化
delay_ms(ms);                  // 毫秒延时
delay_us(us);                  // 微秒延时
read_reg(addr);                // 读取寄存器
write_reg(addr, value);        // 写入寄存器
```

### 调试技巧

1. **启用调试模式**:
```bash
make debug example=hello
```

2. **查看内存映射**:
```bash
# 编译后查看生成的.map文件
cat build/hello/hello.map
```

3. **串口调试**:
```bash
# 启动串口监视器
make monitor

# 或使用screen
screen /dev/ttyUSB0 115200
```

4. **检查配置**:
```bash
make check-config
```

### 故障排除

#### 常见问题

1. **工具链未找到**
   ```
   错误: RISC-V工具链未找到
   ```
   解决：安装RISC-V GNU工具链并设置正确的PATH

2. **串口权限问题**
   ```
   错误: 没有串口设备的读写权限
   ```
   解决：添加用户到dialout组或使用sudo

3. **设备未检测到**
   ```
   错误: 未检测到设备
   ```
   解决：检查USB连接和驱动安装

4. **编译错误**
   ```
   错误: 链接脚本未找到
   ```
   解决：检查平台配置和链接脚本路径

#### 调试命令

```bash
# 检查依赖
make install-deps

# 列出可用示例
make list-examples

# 列出可用平台
make list-platforms

# 清理构建文件
make clean
```

### 扩展开发

#### 添加新平台支持

1. 创建平台目录：`platforms/<平台名>/`
2. 创建配置文件：`platforms/<平台名>/config.mk`
3. 创建链接脚本：`linker/platforms/<平台名>/<板卡>.lds`
4. 更新下载脚本：修改 `scripts/flash.sh`

#### 添加新外设驱动

1. 在 `core/` 目录下创建驱动文件
2. 定义寄存器地址和位定义
3. 实现驱动函数
4. 更新 `system.h` 中的内存映射

#### 自定义链接脚本

可以根据需要修改链接脚本来调整内存布局：

```ld
MEMORY {
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 128K
    FLASH (rx) : ORIGIN = 0x00100000, LENGTH = 1M
}
```

## 许可证

本项目遵循与PicoRV32相同的ISC许可证。 