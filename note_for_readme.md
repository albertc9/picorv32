## 笔记

### 仓库中的文件 from README.md

- README.md
- picorv32.v：包含PicoRV32 CPU及其变体的Verilog模块。
- Makefile和testbench：基本测试环境和测试平台。
- firmware/：简单的测试固件。
- tests/：简单的指令级测试。
- dhrystone/：运行Dhrystone基准测试的简单测试固件。
- picosoc/：使用PicoRV32的简单SoC示例。
- scripts/：各种脚本和示例。

### 核心module参数 from README.md

- ENABLE_COUNTERS：启用对RDCYCLE[H]、RDTIME[H]和RDINSTRET[H]指令的支持。
- ENABLE_REGS_16_31：启用对寄存器x16..x31的支持。
- ENABLE_REGS_DUALPORT：启用双端口寄存器文件。
- LATCHED_MEM_RDATA：设置为1时，外部电路保持mem_rdata稳定。
- TWO_STAGE_SHIFT：启用两阶段移位操作。
- BARREL_SHIFTER：启用桶形移位器。
- TWO_CYCLE_COMPARE：在条件分支指令中添加一个额外的时钟周期延迟。
- TWO_CYCLE_ALU：在ALU数据路径中添加一个额外的FF阶段。
- COMPRESSED_ISA：启用对RISC-V压缩指令集的支持。
- CATCH_MISALIGN：启用对未对齐内存访问的捕获。
- CATCH_ILLINSN：启用对非法指令的捕获。
- ENABLE_PCPI：启用外部Pico协处理器接口。
- ENABLE_MUL：启用乘法指令支持。
- ENABLE_FAST_MUL：启用快速乘法指令支持。
- ENABLE_DIV：启用除法指令支持。
- ENABLE_IRQ：启用IRQ支持。
- ENABLE_TRACE：启用执行跟踪。
- REGS_INIT_ZERO：初始化所有寄存器为零。
- MASKED_IRQ：永久禁用的IRQ位掩码。
- LATCHED_IRQ：指示IRQ是“锁存”的位掩码。
- PROGADDR_RESET：程序的起始地址。
- PROGADDR_IRQ：中断处理程序的起始地址。
- STACKADDR：堆栈指针的初始化值。


