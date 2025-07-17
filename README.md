# PicoRV32 - PicoForFPGA Branch

基于原生PicoRV32 RISC-V CPU的完整SoC项目，专为FPGA开发整理。

## 项目结构

本项目已重新整理为 **PicoForFPGA**，所有核心文件都在 `picoForFPGA/` 目录中：

```
picoForFPGA/
├── rtl/                          # RTL设计文件
│   ├── core/picorv32.v          # CPU核心
│   ├── soc/picosoc.v            # SoC顶层
│   └── peripheral/               # 外设模块
│       ├── simpleuart.v         # UART控制器
│       ├── spiflash.v           # SPI Flash控制器
│       └── spimemio.v           # SPI内存控制器
├── firmware/                     # 固件代码
├── testbench/                    # 测试平台
├── constraints/                  # 约束文件模板
├── scripts/                      # 辅助脚本
├── docs/                         # 文档
└── riscv-gnu-toolchain-riscv32i/ # RISC-V工具链
```

## 主要特性

- **原生PicoRV32**: 基于官方PicoRV32 CPU核心
- **完整SoC**: 包含CPU、外设、固件的完整系统
- **Vivado友好**: 专为Vivado开发优化，包含自动化脚本
- **工具链集成**: 包含RISC-V工具链，可直接编译程序
- **易扩展**: 清晰的模块化结构，便于添加新功能

## 许可证

ISC License

## 相关链接

- [PicoRV32原项目](https://github.com/cliffordwolf/picorv32)
- [RISC-V规范](https://riscv.org/specifications/)

---

**注意**: 本项目已重新整理，所有开发工作在 `picoForFPGA/` 目录中进行。