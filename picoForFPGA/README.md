# PicoForFPGA

基于原生PicoRV32 RISC-V CPU的完整SoC项目，专为FPGA开发整理。

## 项目结构

```
picoForFPGA/
├── rtl/                          # RTL设计文件
│   ├── core/picorv32.v          # CPU核心
│   ├── soc/                     # SoC相关模块
│   │   ├── picosoc.v            # 基础SoC顶层（完整接口）
│   │   └── picosoc_top.v        # 端口优化SoC顶层（减少端口）
│   └── peripheral/               # 外设模块
│       ├── simpleuart.v         # UART控制器
│       ├── spiflash.v           # SPI Flash控制器
│       └── spimemio.v           # SPI内存控制器
├── firmware/                     # 固件代码
│   ├── examples/hello/main.c    # Hello World示例
│   ├── lib/start.S              # 启动代码
│   ├── lib/system.h             # 系统头文件
│   ├── linker/sections.lds      # 链接脚本
│   └── build/                   # 构建目录
├── testbench/                    # 测试平台
│   └── picosoc_tb.v             # SoC测试平台
├── constraints/                  # 约束文件模板
│   ├── vivado_template.xdc      # Vivado通用约束
│   ├── quartus_template.qsf     # Quartus约束
│   └── artix7_mini.xdc          # 升腾/野火Mini Artix-7专用约束
├── scripts/                      # 辅助脚本
│   ├── check_syntax.sh          # 语法检查
│   ├── build_firmware.sh        # 固件构建
│   ├── run_simulation.sh        # 仿真运行
│   ├── makehex.py               # HEX文件生成
├── docs/                         # 文档
│   └── soc_architecture.md      # SoC架构文档
└── riscv-gnu-toolchain-riscv32i/ # RISC-V工具链
```

## 核心特性

- **原生PicoRV32**: 基于官方PicoRV32 CPU核心
- **完整SoC**: 包含CPU、外设、固件的完整系统
- **双顶层设计**: 提供完整接口和端口优化两个版本
- **Vivado友好**: 专为Vivado开发优化
- **工具链集成**: 包含RISC-V工具链
- **易扩展**: 清晰的模块化结构

## 顶层模块说明

### picosoc.v (基础版本)
- **用途**: 完整的SoC接口，包含所有外设端口
- **适用场景**: 
  - 需要完整外设控制的项目
  - 需要外部中断的项目
  - 需要PCPI协处理器的项目
  - 开发和调试阶段
- **特点**: 提供最大的灵活性和控制能力

### picosoc_top.v (端口优化版本)
- **用途**: 减少外部端口数量，简化FPGA集成
- **适用场景**:
  - 升腾/野火Mini Artix-7等资源受限的FPGA
  - 只需要基本功能（UART + Flash）的项目
  - 生产环境部署
- **特点**: 
  - 仅暴露9个外部引脚
  - QSPI Flash时钟复用优化
  - 内部处理未使用的接口

## 内存映射

| 地址范围 | 描述 |
|---------|------|
| 0x00000000 - 0x00000FFF | 内部SRAM (4KB) |
| 0x00100000 - 0x001FFFFF | SPI Flash (1MB) |
| 0x02000000 - 0x02000003 | SPI Flash配置寄存器 |
| 0x02000004 - 0x02000007 | UART时钟分频器 |
| 0x02000008 - 0x0200000B | UART数据寄存器 |
| 0x03000000 - 0xFFFFFFFF | 用户外设空间 |

## 外设说明

### UART控制器
- 支持标准UART通信
- 可配置波特率
- 简单的发送/接收接口

### SPI Flash控制器
- 支持标准SPI Flash
- 内存映射访问
- 可配置SPI模式
- **优化版本**: 时钟通过STARTUPE2输出到CCLK

## FPGA集成

### 升腾/野火Mini Artix-7 (推荐使用优化版本)
1. 在Vivado中创建新项目
2. 按顺序添加RTL文件：
   - `rtl/core/picorv32.v`
   - `rtl/peripheral/simpleuart.v`
   - `rtl/peripheral/spiflash.v`
   - `rtl/peripheral/spimemio.v`
   - `rtl/soc/picosoc.v` (基础版本)
   - `rtl/soc/picosoc_top.v` (优化版本，设为顶层)
3. 添加约束文件：`constraints/artix7_mini.xdc`
4. 综合并生成比特流

### 其他FPGA平台或需要完整接口
1. 使用基础SoC模块：`rtl/soc/picosoc.v` (设为顶层)
2. 参考约束模板：`constraints/vivado_template.xdc`
3. 根据具体硬件调整引脚分配

## 约束文件说明

### artix7_mini.xdc
- 专为升腾/野火Mini Artix-7 XC7A100T-FGG484设计
- 包含完整的引脚分配和电气特性设置
- 支持QSPI Flash的CCLK时钟复用
- 优化的驱动强度和转换速率设置

## 许可证

ISC License

## 相关链接

- [PicoRV32原项目](https://github.com/cliffordwolf/picorv32)
- [RISC-V规范](https://riscv.org/specifications/) 