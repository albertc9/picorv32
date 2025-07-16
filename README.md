# PicoRV32 - 一款大小优化的RISC-V CPU
======================================

PicoRV32 是一个实现 [RISC-V RV32IMC 指令集](http://riscv.org/)的CPU核心。
它可以配置为 RV32E、RV32I、RV32IC、RV32IM 或 RV32IMC 核心，并且可选地
包含一个内建的中断控制器。

## 项目结构

本项目已经重新整理为更适合FPGA开发的结构：

```
├── fpga/                    # FPGA开发项目（主要目录）
│   ├── rtl/                # RTL设计文件
│   ├── constraints/        # 约束文件
│   ├── simulation/         # 仿真文件
│   ├── examples/          # FPGA示例
│   ├── scripts/           # 脚本文件
│   ├── firmware/          # 固件代码
│   └── tests/             # 测试文件
├── README.md              # 本文件
├── README_En.md           # 英文说明
├── COPYING                # 许可证
└── Makefile               # 主构建文件
```

## 快速开始

### 1. 查看帮助
```bash
make help
```

### 2. 进入FPGA项目
```bash
make fpga
```

### 3. 运行测试
```bash
make test
```

### 4. 构建固件
```bash
make firmware
```

## 支持的FPGA平台

- **iCE40系列**: HX8K、iCEBreaker等
- **Xilinx 7系列**: Artix-7、Kintex-7、Virtex-7
- **通用平台**: 可移植到其他FPGA

## 详细文档

- [FPGA项目文档](fpga/README.md) - 详细的FPGA开发指南
- [重新整理总结](fpga/RESTRUCTURE_SUMMARY.md) - 项目重新整理说明
- [英文文档](README_En.md) - 原始英文说明

## 许可证

PicoRV32是自由开源硬件，遵循 [ISC许可证](http://en.wikipedia.org/wiki/ISC_license)
（类似于MIT许可证或2条款BSD许可证）。

## 贡献

欢迎提交问题报告和拉取请求来改进这个项目。

---

**注意**: 本项目已经重新整理，主要开发工作现在在 `fpga/` 目录中进行。