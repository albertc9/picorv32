# PicoForFPGA

基于原生PicoRV32 RISC-V CPU的完整SoC项目，专为FPGA开发整理。

## 项目结构

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
│   ├── examples/hello/main.c    # Hello World示例
│   ├── lib/start.S              # 启动代码
│   ├── lib/system.h             # 系统头文件
│   ├── linker/sections.lds      # 链接脚本
│   └── build/                   # 构建目录
├── testbench/                    # 测试平台
│   └── picosoc_tb.v             # SoC测试平台
├── constraints/                  # 约束文件模板
│   ├── vivado_template.xdc      # Vivado约束
│   └── quartus_template.qsf     # Quartus约束
├── scripts/                      # 辅助脚本
│   ├── check_syntax.sh          # 语法检查
│   ├── build_firmware.sh        # 固件构建
│   ├── run_simulation.sh        # 仿真运行
│   ├── start_vivado.sh          # Vivado启动
│   ├── create_vivado_project.tcl # Vivado项目创建
│   └── makehex.py               # HEX文件生成
├── docs/                         # 文档
│   └── soc_architecture.md      # SoC架构文档
└── riscv-gnu-toolchain-riscv32i/ # RISC-V工具链
```

## 核心特性

- **原生PicoRV32**: 基于官方PicoRV32 CPU核心
- **完整SoC**: 包含CPU、外设、固件的完整系统
- **Vivado友好**: 专为Vivado开发优化
- **工具链集成**: 包含RISC-V工具链
- **易扩展**: 清晰的模块化结构

## 快速开始

### 1. 语法检查
```bash
./scripts/check_syntax.sh
```

### 2. 运行仿真
```bash
./scripts/run_simulation.sh
```

### 3. 构建固件
```bash
./scripts/build_firmware.sh
```

### 4. Vivado集成
```bash
./scripts/start_vivado.sh
```

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

## FPGA集成

### Vivado集成
1. 运行 `./scripts/start_vivado.sh` 创建项目
2. 在Vivado中打开 `vivado_project/picosoc_fpga.xpr`
3. 根据需要修改约束文件
4. 综合和实现

### 手动集成
1. 在Vivado中创建新项目
2. 按顺序添加RTL文件：
   - `rtl/core/picorv32.v`
   - `rtl/peripheral/simpleuart.v`
   - `rtl/peripheral/spiflash.v`
   - `rtl/peripheral/spimemio.v`
   - `rtl/soc/picorv32_soc.v`
   - `rtl/soc/picosoc.v`
3. 设置顶层模块为 `picosoc`
4. 添加约束文件

## 许可证

ISC License

## 相关链接

- [PicoRV32原项目](https://github.com/cliffordwolf/picorv32)
- [RISC-V规范](https://riscv.org/specifications/) 