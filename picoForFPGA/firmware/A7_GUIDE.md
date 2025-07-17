# PicoRV32 A7系列FPGA使用指南

## 概述

本指南专门针对Xilinx A7系列FPGA（如Arty A7-35T/100T、Basys3等）的PicoRV32固件下载和运行。

## 硬件要求

### 支持的板卡
- **Arty A7-35T**: 推荐用于学习和开发
- **Arty A7-100T**: 性能更好，资源更丰富
- **Basys3**: 适合教学和实验
- **其他A7系列板卡**: 需要适配

### 硬件连接
1. **USB连接**: 使用USB-C或USB-B连接线连接FPGA板到电脑
2. **电源**: 确保FPGA板有稳定的电源供应
3. **串口**: 用于调试和通信

## 软件环境准备

### 必需软件
1. **RISC-V GNU工具链**
   ```bash
   # Ubuntu/Debian
   sudo apt install gcc-riscv64-unknown-elf
   
   # 或从官网下载
   # https://github.com/riscv/riscv-gnu-toolchain
   ```

2. **Xilinx Vivado** (推荐2023.2或更新版本)
   - 下载地址: https://www.xilinx.com/support/download.html
   - 安装时选择A7系列支持

3. **Make工具**
   ```bash
   sudo apt install make
   ```

4. **Python 3** (用于脚本)
   ```bash
   sudo apt install python3
   ```

### 环境变量设置
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export PATH=$PATH:/opt/Xilinx/Vivado/2023.2/bin
export PATH=$PATH:/path/to/riscv-gnu-toolchain/bin
```

## 配置步骤

### 1. 配置目标平台

编辑 `config.mk` 文件：
```makefile
# 目标平台
PLATFORM = xilinx

# 具体板卡 (根据您的板卡选择)
BOARD = arty    # 或 basys3

# 工具链前缀
TOOLCHAIN_PREFIX = riscv32-unknown-elf-
```

### 2. 检查配置

```bash
# 检查当前配置
make check-config

# 检查依赖
make install-deps
```

## 编译和下载流程

### 1. 编译示例程序

```bash
# 编译Hello World示例
make build example=hello

# 编译LED闪烁示例
make build example=blink

# 编译UART测试示例
make build example=uart_test
```

### 2. 生成FPGA比特流

**重要**: 在下载固件之前，您需要先有FPGA的比特流文件（.bit文件）。

#### 方法1: 使用现有的比特流
如果您已经有包含PicoRV32的比特流文件：
```bash
# 将比特流文件放在项目根目录
cp your_picorv32_design.bit ./bitstream.bit
```

#### 方法2: 创建新的比特流
1. 打开Vivado
2. 创建新项目，选择您的A7板卡
3. 添加PicoRV32 IP核
4. 生成比特流文件

### 3. 下载到FPGA

#### 下载比特流
```bash
# 使用Vivado下载比特流
vivado -mode batch -source scripts/xilinx_flash.tcl -tclargs bitstream.bit
```

#### 下载固件（可选）
如果您的设计支持运行时固件更新：
```bash
# 下载固件到Flash
make flash example=hello
```

### 4. 运行和调试

#### 启动串口监视器
```bash
# 自动检测串口设备
make monitor

# 或手动指定设备
./scripts/monitor.sh -d /dev/ttyUSB0 -b 115200
```

#### 使用screen
```bash
screen /dev/ttyUSB0 115200
```

#### 使用minicom
```bash
minicom -D /dev/ttyUSB0 -b 115200
```

## 故障排除

### 常见问题

#### 1. 工具链未找到
```
错误: RISC-V工具链未找到
```
**解决方案**:
- 检查工具链安装
- 设置正确的PATH环境变量
- 验证工具链前缀设置

#### 2. Vivado未找到
```
错误: vivado命令未找到
```
**解决方案**:
- 安装Xilinx Vivado
- 设置Vivado路径到PATH
- 或修改 `platforms/xilinx/config.mk` 中的 `VIVADO_PATH`

#### 3. 设备未检测到
```
错误: 未检测到硬件设备
```
**解决方案**:
- 检查USB连接
- 安装Xilinx USB驱动
- 检查板卡电源
- 验证板卡型号设置

#### 4. 串口权限问题
```
错误: 没有串口设备的读写权限
```
**解决方案**:
```bash
# 添加用户到dialout组
sudo usermod -a -G dialout $USER

# 重新登录或重启
sudo chmod 666 /dev/ttyUSB0
```

#### 5. 编译错误
```
错误: 链接脚本未找到
```
**解决方案**:
- 检查平台和板卡配置
- 确保链接脚本存在
- 验证目录结构

### 调试技巧

#### 1. 启用调试模式
```bash
make debug example=hello
```

#### 2. 查看内存映射
```bash
# 编译后查看生成的.map文件
cat build/hello/hello.map
```

#### 3. 检查设备连接
```bash
# 检查USB设备
lsusb | grep Xilinx

# 检查串口设备
ls /dev/ttyUSB*
```

#### 4. 验证比特流
```bash
# 检查比特流文件
file bitstream.bit
```

## 高级配置

### 自定义内存布局

编辑 `linker/platforms/xilinx/arty.lds`：
```ld
MEMORY {
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 128K
    FLASH (rx) : ORIGIN = 0x00100000, LENGTH = 16M
}
```

### 自定义编译选项

编辑 `platforms/xilinx/config.mk`：
```makefile
# 添加自定义编译选项
CFLAGS += -DCUSTOM_FEATURE
CFLAGS += -DDEBUG_LEVEL=2
```

### 添加新板卡支持

1. 创建板卡配置文件
2. 创建链接脚本
3. 更新下载脚本
4. 测试验证

## 性能优化

### 编译优化
```makefile
# 启用优化
CFLAGS += -O2 -fomit-frame-pointer

# 启用链接时优化
LDFLAGS += -flto
```

### 内存优化
- 调整堆栈大小
- 优化内存布局
- 使用BRAM缓存

## 扩展开发

### 添加新外设
1. 定义寄存器地址
2. 实现驱动函数
3. 更新内存映射
4. 测试验证

### 添加新示例
1. 创建示例目录
2. 编写main.c
3. 更新Makefile
4. 测试运行

## 技术支持

### 文档资源
- [PicoRV32官方文档](https://github.com/cliffordwolf/picorv32)
- [Xilinx A7系列文档](https://www.xilinx.com/products/silicon-devices/fpga/artix-7.html)
- [RISC-V规范](https://riscv.org/specifications/)

### 社区支持
- GitHub Issues
- RISC-V论坛
- Xilinx社区

## 许可证

本项目遵循与PicoRV32相同的ISC许可证。 