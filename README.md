# PicoRV32 - PicoForFPGA Branch

基于原生PicoRV32 RISC-V CPU的完整SoC项目，专为FPGA开发整理。

## 项目结构

本项目已重新整理为 **PicoForFPGA**，所有核心文件都在 `picoForFPGA/` 目录中：

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
├── testbench/                    # 测试平台
├── constraints/                  # 约束文件模板
│   ├── vivado_template.xdc      # Vivado通用约束
│   ├── quartus_template.qsf     # Quartus约束
│   └── artix7_mini.xdc          # 升腾/野火Mini专用约束
├── scripts/                      # 辅助脚本
├── docs/                         # 文档
└── riscv-gnu-toolchain-riscv32i/ # RISC-V工具链
```

## 主要特性

- **原生PicoRV32**: 基于官方PicoRV32 CPU核心
- **完整SoC**: 包含CPU、外设、固件的完整系统
- **双顶层设计**: 提供完整接口和端口优化两个版本
- **QSPI Flash优化**: 支持CCLK时钟复用，减少布线复杂度
- **Vivado友好**: 专为Vivado开发优化，包含自动化脚本
- **工具链集成**: 包含RISC-V工具链，可直接编译程序
- **易扩展**: 清晰的模块化结构，便于添加新功能

## 顶层模块说明

### picosoc.v (基础版本)
- 完整的SoC接口，包含所有外设端口
- 适合需要完整控制的项目和开发调试

### picosoc_top.v (端口优化版本)
- 仅暴露9个外部引脚，简化FPGA集成
- 推荐用于升腾/野火Mini等资源受限的FPGA

## 快速开始

### 升腾/野火Mini Artix-7 (推荐使用优化版本)
1. 进入 `picoForFPGA/` 目录
2. 添加所有RTL文件（包括两个顶层模块）
3. 使用 `picosoc_top.v` 作为顶层模块
4. 应用 `constraints/artix7_mini.xdc` 约束文件
5. 参考详细文档：`picoForFPGA/README.md`

### 需要完整接口的项目
1. 使用 `picosoc.v` 作为顶层模块
2. 参考 `constraints/vivado_template.xdc` 约束模板

## 许可证

ISC License

## 相关链接

- [PicoRV32原项目](https://github.com/cliffordwolf/picorv32)
- [RISC-V规范](https://riscv.org/specifications/)

---

**注意**: 本项目已重新整理，所有开发工作在 `picoForFPGA/` 目录中进行。