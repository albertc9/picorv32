# PicoRV32 FPGA 项目
====================

这是一个重新整理的PicoRV32项目，专门为FPGA开发进行了优化。

## 项目结构

```
fpga/
├── rtl/                    # RTL设计文件
│   ├── core/              # CPU核心文件
│   │   └── picorv32.v     # PicoRV32 CPU核心
│   ├── peripherals/       # 外设模块
│   │   ├── picosoc.v      # SoC顶层模块
│   │   ├── spimemio.v     # SPI内存控制器
│   │   ├── simpleuart.v   # 简单UART
│   │   └── spiflash.v     # SPI Flash控制器
│   └── memory/            # 内存模块
├── constraints/           # 约束文件
│   ├── *.pcf             # iCE40引脚约束
│   └── *.xdc             # Xilinx约束文件
├── simulation/           # 仿真文件
│   ├── testbench.v       # 主测试平台
│   ├── testbench_ez.v    # 简单测试平台
│   └── showtrace.py      # 波形查看工具
├── examples/             # FPGA示例
│   ├── ice40/           # iCE40 FPGA示例
│   ├── xilinx7/         # Xilinx 7系列示例
│   └── generic/         # 通用示例
├── scripts/             # 脚本文件
│   ├── synthesis/       # 综合脚本
│   ├── simulation/      # 仿真脚本
│   └── programming/     # 编程脚本
├── firmware/            # 固件代码
├── tests/              # 测试文件
└── dhrystone/          # Dhrystone基准测试
```

## 快速开始

### 1. 检查依赖
```bash
make check-deps
```

### 2. 运行基本测试
```bash
make test
```

### 3. 构建固件
```bash
make firmware
```

### 4. 查看项目结构
```bash
make tree
```

## 支持的FPGA平台

### iCE40系列
- iCE40-HX8K Breakout Board
- iCEBreaker Board
- 其他iCE40兼容板卡

### Xilinx 7系列
- Artix-7
- Kintex-7
- Virtex-7

### 通用平台
- 可移植到其他FPGA平台

## 使用示例

### iCE40示例
```bash
cd examples/ice40
make hx8kprog    # 编程HX8K板卡
make icebprog    # 编程iCEBreaker板卡
```

### 仿真
```bash
cd simulation
make test        # 运行完整测试
make test-ez     # 运行简单测试
```

## 配置选项

PicoRV32支持多种配置选项，可以在实例化时设置：

- `ENABLE_COUNTERS`: 启用性能计数器
- `ENABLE_COUNTERS64`: 启用64位计数器
- `ENABLE_REGS_16_31`: 启用寄存器x16-x31
- `ENABLE_REGS_DUALPORT`: 启用双端口寄存器文件
- `COMPRESSED_ISA`: 启用压缩指令集
- `CATCH_MISALIGN`: 捕获内存对齐错误
- `CATCH_ILLINSN`: 捕获非法指令

## 内存映射

### 标准内存映射
- `0x00000000 - 0x00FFFFFF`: 内部SRAM
- `0x01000000 - 0x01FFFFFF`: 外部SPI Flash
- `0x02000000 - 0x02000003`: SPI Flash控制器配置
- `0x02000004 - 0x02000007`: UART时钟分频器
- `0x02000008 - 0x0200000B`: UART发送/接收数据
- `0x03000000 - 0xFFFFFFFF`: 用户外设

## 开发指南

### 添加新的外设
1. 在`rtl/peripherals/`中创建新的Verilog模块
2. 在SoC顶层模块中实例化
3. 更新内存映射
4. 添加相应的固件驱动

### 添加新的FPGA平台
1. 在`examples/`中创建新目录
2. 复制并修改现有示例
3. 更新约束文件
4. 创建相应的Makefile

### 运行仿真
```bash
cd simulation
iverilog -o testbench.vvp testbench.v ../rtl/core/picorv32.v
vvp testbench.vvp
```

## 故障排除

### 常见问题
1. **工具链未找到**: 运行`make check-deps`检查依赖
2. **综合失败**: 检查约束文件是否正确
3. **仿真失败**: 确保所有依赖文件都存在

### 调试技巧
- 使用`showtrace.py`查看波形
- 检查固件是否正确编译
- 验证内存映射配置

## 许可证

本项目遵循ISC许可证，详见LICENSE文件。

## 贡献

欢迎提交问题报告和拉取请求来改进这个项目。 