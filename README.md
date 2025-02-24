[![.github/workflows/ci.yml](https://github.com/YosysHQ/picorv32/actions/workflows/ci.yml/badge.svg)](https://github.com/YosysHQ/picorv32/actions/workflows/ci.yml)

PicoRV32 - 一款大小优化的RISC-V CPU
======================================

PicoRV32 是一个实现 [RISC-V RV32IMC 指令集](http://riscv.org/)的CPU核心。
它可以配置为 RV32E、RV32I、RV32IC、RV32IM 或 RV32IMC 核心，并且可选地
包含一个内建的中断控制器。

工具（gcc、binutils等）可以通过 [RISC-V官网](https://riscv.org/software-status/) 获取。
PicoRV32附带的示例期望安装了不同的RV32工具链，路径为`/opt/riscv32i[m][c]`。详细信息请参见
[下面的构建说明](#构建纯RV32I工具链)。
许多Linux发行版现在包含了RISC-V的工具链（例如，Ubuntu 20.04包含`gcc-riscv64-unknown-elf`）。
要使用这些工具链进行编译，请相应设置`TOOLCHAIN_PREFIX`（例如，`make TOOLCHAIN_PREFIX=riscv64-unknown-elf-`）。

PicoRV32是自由开源硬件，遵循 [ISC许可证](http://en.wikipedia.org/wiki/ISC_license)
（类似于MIT许可证或2条款BSD许可证）。

#### 目录

- [特性与典型应用](#特性与典型应用)
- [本仓库中的文件](#本仓库中的文件)
- [Verilog模块参数](#Verilog模块参数)
- [每条指令的周期性能](#每条指令的周期性能)
- [PicoRV32原生内存接口](#PicoRV32原生内存接口)
- [Pico协处理器接口(PCPI)](#Pico协处理器接口(PCPI))
- [IRQ处理的自定义指令](#IRQ处理的自定义指令)
- [构建纯RV32I工具链](#构建纯RV32I工具链)
- [使用newlib为PicoRV32链接二进制文件](#使用newlib为PicoRV32链接二进制文件)
- [评估：在Xilinx 7系列FPGA上的时序和利用率](#评估：在Xilinx 7系列FPGA上的时序和利用率)


特性与典型应用
---------------------------------

- 小巧（7系列Xilinx架构中的750-2000 LUTs）
- 高f<sub>max</sub>（7系列Xilinx FPGA上为250-450 MHz）
- 可选择的原生内存接口或AXI4-Lite主接口
- 可选的IRQ支持（使用简单的自定义ISA）
- 可选的协处理器接口

该CPU旨在作为FPGA设计和ASIC中的辅助处理器使用。由于其高f<sub>max</sub>，它可以集成到大多数现有设计中，而无需跨越时钟域。当以较低频率运行时，它会有大量的时序冗余，因此可以在不影响时序收敛的情况下添加到设计中。

为了更小的尺寸，可以禁用对寄存器`x16`..`x31`以及`RDCYCLE[H]`、`RDTIME[H]`和`RDINSTRET[H]`指令的支持，将处理器转换为RV32E核心。

此外，还可以选择双端口寄存器文件和单端口寄存器文件的实现。前者提供更好的性能，而后者则产生更小的核心。

*注意：在实现寄存器文件的架构中（例如许多FPGA），禁用16个上层寄存器和/或禁用双端口寄存器文件可能不会进一步减少核心尺寸。*

该核心存在三种变体：`picorv32`、`picorv32_axi`和`picorv32_wb`。
第一种提供一个简单的原生内存接口，适用于简单环境。`picorv32_axi`提供一个AXI-4 Lite主接口，可以
轻松与已经使用AXI标准的现有系统集成。`picorv32_wb`提供一个Wishbone主接口。

提供了一个单独的核心`picorv32_axi_adapter`，用于在原生内存接口与AXI4之间进行桥接。
此核心可用于创建自定义核心，其中包含一个或多个PicoRV32核心，并与本地RAM、ROM和
内存映射外设共同工作，彼此之间使用原生接口通信，并通过AXI4与外部世界通信。

可选的IRQ特性可以用于响应外部事件，实施故障处理程序，或捕获来自更大ISA的指令并在软件中模拟它们。

可选的Pico协处理器接口（PCPI）可用于在外部协处理器中实现非分支指令。
本包中包含实现M标准扩展指令`MUL[H[SU|U]]`和`DIV[U]/REM[U]`的PCPI核心实现。

本仓库中的文件
------------------------

#### README.md

您正在阅读的正是此文件。

#### picorv32.v

此Verilog文件包含以下Verilog模块：

| 模块                     | 描述                                                                 |
| ------------------------ | -------------------------------------------------------------------- |
| `picorv32`               | PicoRV32 CPU核心                                                     |
| `picorv32_axi`           | 带有AXI4-Lite接口的CPU版本                                           |
| `picorv32_axi_adapter`   | 从PicoRV32内存接口到AXI4-Lite的适配器                                |
| `picorv32_wb`            | 带有Wishbone主接口的CPU版本                                          |
| `picorv32_pcpi_mul`      | 实现`MUL[H[SU|U]]`指令的PCPI核心                                     |
| `picorv32_pcpi_fast_mul` | 使用单周期乘法器的`picorv32_pcpi_fast_mul`版本                       |
| `picorv32_pcpi_div`      | 实现`DIV[U]/REM[U]`指令的PCPI核心                                    |

只需将此文件复制到您的项目中。

#### Makefile和testbenches

一个基本的测试环境。运行`make test`来运行标准测试平台(`testbench.v`)
以及标准配置。还有其他测试平台和配置，请参阅
Makefile中的`test_*`目标以了解详情。

运行`make test_ez`来运行`testbench_ez.v`，这是一个非常简单的测试平台，无需外部固件.hex文件。
这对于RISC-V编译工具链不可用的环境非常有用。

*注意：该测试平台使用Icarus Verilog。但是，Icarus Verilog 0.9.7（写作时的最新版本）
有一些BUG会阻止测试平台运行。升级到Icarus Verilog的最新github主分支以运行测试平台。*

#### firmware/

一个简单的测试固件。它运行来自`tests/`的基本测试，某些C代码，测试IRQ
处理和乘法PCPI核心。

`firmware/`中的所有代码都属于公有领域。只需复制您可以使用的部分。

#### tests/

来自[riscv-tests](https://github.com/riscv/riscv-tests)的简单指令级测试。

#### dhrystone/

另一个简单的测试固件，运行Dhrystone基准测试。

#### picosoc/

一个使用PicoRV32的简单示例SoC，可以直接从
内存映射的SPI闪存执行代码。

#### scripts/

用于不同（综合）工具和硬件架构的各种脚本和示例。

Verilog模块参数
-------------------------

以下Verilog模块参数可用于配置PicoRV32
核心。

#### ENABLE_COUNTERS（默认值= 1）

此参数启用对`RDCYCLE[H]`、`RDTIME[H]`和
`RDINSTRET[H]`指令的支持。如果将`ENABLE_COUNTERS`设置为零，这些指令将会导致硬件
陷阱（与任何其他不支持的指令一样）。

*注意：严格来说，`RDCYCLE[H]`、`RDTIME[H]`和`RDINSTRET[H]`
指令对于RV32I核心是必须的。但是，在应用程序代码经过调试和性能分析之后，
这些指令通常不会被遗漏。对于RV32E核心，这些指令是可选的。*

#### ENABLE_COUNTERS64（默认值= 1）

此参数启用对`RDCYCLEH`、`RDTIMEH`和`RDINSTRETH`
指令的支持。如果此参数设置为0，并且`ENABLE_COUNTERS`设置为1，
则只会提供`RDCYCLE`、`RDTIME`和`RDINSTRET`指令。

#### ENABLE_REGS_16_31（默认值= 1）

此参数启用对

寄存器`x16`..`x31`的支持。RV32E ISA
排除了这些寄存器。然而，RV32E ISA规范要求在访问这些寄存器时触发硬件陷阱。
PicoRV32未实现这一点。

#### ENABLE_REGS_DUALPORT（默认值= 1）

寄存器文件可以使用两个或一个读端口实现。双端口
寄存器文件提高了性能，但也可能增加
核心的大小。

#### LATCHED_MEM_RDATA（默认值= 0）

如果在事务后外部电路保持`mem_rdata`稳定，请将此值设置为1。
在默认配置中，PicoRV32核心只期望`mem_rdata`输入在`mem_valid && mem_ready`的周期内有效，并将值
内部锁存。

此参数仅适用于`picorv32`核心。在
`picorv32_axi`和`picorv32_wb`核心中，此参数隐式设置为0。

#### TWO_STAGE_SHIFT（默认值= 1）

默认情况下，移位操作分为两阶段进行：首先按4位单位进行移位，然后按1位单位进行移位。这加速了移位操作，
但增加了额外的硬件。如果将此参数设置为0，则禁用两阶段
移位，以进一步减少核心的大小。

#### BARREL_SHIFTER（默认值= 0）

默认情况下，移位操作通过逐步移位的小量（参见上面的`TWO_STAGE_SHIFT`）进行。启用此选项后，使用一个桶形
移位器来进行操作。

#### TWO_CYCLE_COMPARE（默认值 = 0）

此参数通过在最长数据路径中添加一个额外的FF阶段来稍微放宽时序，但会使条件分支指令的延迟增加一个额外的时钟周期。

*注意：启用此参数在进行时序重排（即“寄存器平衡”）时最为有效。*

#### TWO_CYCLE_ALU（默认值 = 0）

此参数在ALU数据路径中增加一个额外的FF阶段，提高时序性能，但会导致所有使用ALU的指令增加一个时钟周期的延迟。

*注意：启用此参数在进行时序重排（即“寄存器平衡”）时最为有效。*

#### COMPRESSED_ISA（默认值 = 0）

此参数启用对RISC-V压缩指令集的支持。

#### CATCH_MISALIGN（默认值 = 1）

将此值设置为0以禁用捕获内存对齐错误的电路。

#### CATCH_ILLINSN（默认值 = 1）

将此值设置为0以禁用捕获非法指令的电路。

即使此选项设置为0，核心仍会对`EBREAK`指令进行陷阱。启用IRQ时，`EBREAK`通常会触发IRQ 1。将此选项设置为0时，`EBREAK`将使处理器陷阱，而不触发中断。

#### ENABLE_PCPI（默认值 = 0）

将此值设置为1以启用外部Pico协处理器接口（PCPI）。对于像`picorv32_pcpi_mul`这样的内部PCPI核心，不需要外部接口。

#### ENABLE_MUL（默认值 = 0）

此参数启用PCPI，并实例化`picorv32_pcpi_mul`核心，来实现`MUL[H[SU|U]]`指令。仅当同时设置`ENABLE_PCPI`时，外部PCPI接口才会生效。

#### ENABLE_FAST_MUL（默认值 = 0）

此参数启用PCPI，并实例化`picorv32_pcpi_fast_mul`核心，来实现`MUL[H[SU|U]]`指令。仅当同时设置`ENABLE_PCPI`时，外部PCPI接口才会生效。

如果同时设置了`ENABLE_MUL`和`ENABLE_FAST_MUL`，则会忽略`ENABLE_MUL`设置，并实例化快速乘法器核心。

#### ENABLE_DIV（默认值 = 0）

此参数启用PCPI，并实例化`picorv32_pcpi_div`核心，来实现`DIV[U]/REM[U]`指令。仅当同时设置`ENABLE_PCPI`时，外部PCPI接口才会生效。

#### ENABLE_IRQ（默认值 = 0）

将此值设置为1以启用IRQ。（参见下文的“IRQ处理的自定义指令”部分，了解IRQ的详细讨论）

#### ENABLE_IRQ_QREGS（默认值 = 1）

将此值设置为0以禁用对`getq`和`setq`指令的支持。如果没有q寄存器，IRQ返回地址将存储在x3（gp）寄存器中，IRQ位掩码存储在x4（tp）寄存器中，分别是全局指针和线程指针寄存器，符合RISC-V ABI规范。普通C代码生成的代码将不会与这些寄存器交互。

当`ENABLE_IRQ`设置为0时，q寄存器的支持始终被禁用。

#### ENABLE_IRQ_TIMER（默认值 = 1）

将此值设置为0以禁用对`timer`指令的支持。

当`ENABLE_IRQ`设置为0时，始终禁用定时器支持。

#### ENABLE_TRACE（默认值 = 0）

通过`trace_valid`和`trace_data`输出端口生成执行跟踪。
要演示此功能，请运行`make test_vcd`以创建跟踪文件，然后运行`python3 showtrace.py testbench.trace firmware/firmware.elf`进行解码。

#### REGS_INIT_ZERO（默认值 = 0）

将此值设置为1以将所有寄存器初始化为零（使用Verilog的`initial`块）。这对于仿真或形式验证非常有用。

#### MASKED_IRQ（默认值 = 32'h 0000_0000）

此位掩码中的1位对应于永久禁用的IRQ。

#### LATCHED_IRQ（默认值 = 32'h ffff_ffff）

此位掩码中的1位表示相应的IRQ是“锁存”的，即当IRQ线高电平仅持续一个时钟周期时，interrupt将被标记为待处理，并保持待处理状态，直到中断处理程序被调用（也称为“脉冲中断”或“边沿触发中断”）。

将此位掩码中的某个位设置为0，可以将中断线路转换为“电平敏感”的中断。

#### PROGADDR_RESET（默认值 = 32'h 0000_0000）

程序的起始地址。

#### PROGADDR_IRQ（默认值 = 32'h 0000_0010）

中断处理程序的起始地址。

#### STACKADDR（默认值 = 32'h ffff_ffff）

当此参数的值不同于0xffffffff时，寄存器`x2`（堆栈指针）将在复位时初始化为此值。（其他所有寄存器保持未初始化。）请注意，RISC-V调用约定要求堆栈指针对齐到16字节边界（RV32I软浮动调用约定需要对齐到4字节）。

每条指令的周期性能
----------------------------------

*简单提醒：此核心优化侧重于尺寸和f<sub>max</sub>，而不是性能。*

除非另有说明，以下数字适用于启用`ENABLE_REGS_DUALPORT`并连接到能够在一个时钟周期内处理请求的内存的PicoRV32。

平均每条指令的周期数（CPI）约为4，具体取决于代码中指令的组合。个别指令的CPI数字可以
在下表中找到。表中的"CPI (SP)"列包含没有启用`ENABLE_REGS_DUALPORT`的核心的CPI值。

| 指令                   |  CPI | CPI (SP) |
| ---------------------- | ----:| --------:|
| 直接跳转（jal）         |    3 |        3 |
| ALU寄存器 + 立即数      |    3 |        3 |
| ALU寄存器 + 寄存器      |    3 |        4 |
| 分支（未取）            |    3 |        4 |
| 内存加载                |    5 |        5 |
| 内存存储                |    5 |        6 |
| 分支（已取）            |    5 |        6 |
| 间接跳转（jalr）        |    6 |        6 |
| 移位操作                | 4-14 |     4-15 |

当`ENABLE_MUL`启用时，`MUL`指令将在40个周期内执行，`MULH[SU|U]`指令将在72个周期内执行。

当`ENABLE_DIV`启用时，`DIV[U]/REM[U]`指令将在40个周期内执行。

当启用`BARREL_SHIFTER`时，移位操作的时间与其他ALU操作相同。

以下是启用了`ENABLE_FAST_MUL`、`ENABLE_DIV`和`BARREL_SHIFTER`选项的核心的Dhrystone基准测试结果。

Dhrystone基准测试结果：0.516 DMIPS/MHz（908 Dhrystones/秒/MHz）

对于Dhrystone基准，平均CPI为4.100。

在没有使用前瞻内存接口（通常需要为最大时钟频率）的情况下，结果下降到0.305 DMIPS/MHz和5.232 CPI。


PicoRV32原生内存接口
--------------------------------

PicoRV32的原生内存接口是一个简单的有效-准备接口，能够一次运行一个内存传输：

    输出        mem_valid
    输出        mem_instr
    输入         mem_ready

    输出 [31:0] mem_addr
    输出 [31:0] mem_wdata
    输出 [ 3:0] mem_wstrb
    输入  [31:0] mem_rdata

核心通过使`mem_valid`有效来启动内存传输。有效信号将保持高电平，直到对端使`mem_ready`有效。所有核心输出在`mem_valid`周期内是稳定的。如果内存传输是指令获取，核心会使`mem_instr`有效。

#### 读传输

在读传输中，`mem_wstrb`的值为0，`mem_wdata`无效。

内存读取`mem_addr`地址，并在`mem_ready`高电平的周期内将读取值提供到`mem_rdata`。

不需要外部等待周期

。内存读取可以是异步的，`mem_ready`和`mem_valid`在同一周期内变高，或者`mem_ready`被绑定为常量1。

#### 写传输

在写传输中，`mem_wstrb`非0，`mem_rdata`无效。内存将数据写入`mem_wdata`到`mem_addr`地址，并通过使`mem_ready`有效来确认传输。

`mem_wstrb`的4位是写使能位，用于地址中指定字的四个字节。只有8个值`0000`、`1111`、`1100`、`0011`、`1000`、`0100`、`0010`和`0001`是有效的，即：不写、写32位、写上16位、写下16位或写一个字节。

不需要外部等待周期。内存可以立即确认写操作，`mem_ready`在同一周期内变高，或`mem_ready`被绑定为常量1。

#### 前瞻接口

PicoRV32核心还提供了一个“前瞻内存接口”，它比正常接口提前一个时钟周期提供有关下一个内存传输的所有信息。

    输出        mem_la_read
    输出        mem_la_write
    输出 [31:0] mem_la_addr
    输出 [31:0] mem_la_wdata
    输出 [ 3:0] mem_la_wstrb

在`mem_valid`变高的前一个时钟周期，此接口将输出`mem_la_read`或`mem_la_write`的脉冲，以指示下一时钟周期将开始读或写操作。

*注意：信号`mem_la_read`、`mem_la_write`和`mem_la_addr`由PicoRV32核心内的组合电路驱动。使用前瞻接口时，可能比使用上述正常内存接口更难实现时序收敛。*


Pico协处理器接口（PCPI）
----------------------------------

Pico协处理器接口（PCPI）
----------------------------------

Pico协处理器接口（PCPI）可以用于在外部核心中实现非分支指令：

    输出        pcpi_valid
    输出 [31:0] pcpi_insn
    输出 [31:0] pcpi_rs1
    输出 [31:0] pcpi_rs2
    输入         pcpi_wr
    输入  [31:0] pcpi_rd
    输入         pcpi_wait
    输入         pcpi_ready

当遇到不支持的指令且启用了PCPI特性时（参见上文的`ENABLE_PCPI`），
`pcpi_valid`会被置为高，指令字本身会输出到`pcpi_insn`，`rs1`和`rs2`字段会被解码，
并且它们的值会通过`pcpi_rs1`和`pcpi_rs2`输出。

外部PCPI核心可以解码指令、执行它，并在指令执行完成时使`pcpi_ready`有效。
可选地，结果值可以写入`pcpi_rd`，并使`pcpi_wr`有效。PicoRV32核心随后会解码指令中的`rd`字段，
并将`pcpi_rd`中的值写入相应的寄存器。

当没有外部PCPI核心在16个时钟周期内响应指令时，系统会触发非法指令异常，并调用相应的中断处理程序。
如果一个PCPI核心需要更多的时钟周期来执行指令，则应该在成功解码指令后尽早使`pcpi_wait`有效，
并在`pcpi_ready`有效之前一直保持`pcpi_wait`有效。这将防止PicoRV32核心触发非法指令异常。


IRQ处理的自定义指令
------------------------------------

*注意：PicoRV32中的IRQ处理功能不遵循RISC-V特权ISA规范。相反，使用一小套非常简单的自定义指令来实现IRQ处理，具有最小的硬件开销。*

以下自定义指令仅在通过`ENABLE_IRQ`参数启用IRQ时支持（见上文）。

PicoRV32核心内建一个具有32个中断输入的中断控制器。中断可以通过激活核心的`irq`输入中的相应位来触发。

当中断处理程序开始时，已处理的中断的`eoi`（中断结束）信号会变为高电平。当中断处理程序返回时，`eoi`信号会变为低电平。

IRQ 0-2可以由以下内建的中断源内部触发：

| IRQ  | 中断源                            |
| ---- | ---------------------------------- |
|  0   | 定时器中断                         |
|  1   | `EBREAK`/`ECALL` 或非法指令       |
|  2   | 总线错误（未对齐的内存访问）      |

这些中断也可以由外部源触发，如通过PCPI连接的协处理器。

该核心有4个额外的32位寄存器`q0..q3`，用于IRQ处理。当中断处理程序被调用时，寄存器`q0`包含返回地址，`q1`包含要处理的所有IRQ的位掩码。这意味着，当`q1`中设置了多个位时，调用中断处理程序需要处理多个IRQ。

当启用压缩指令支持时，`q0`的最低有效位（LSB）会被设置，当中断指令是压缩指令时。中断处理程序可以使用这个信息来解码中断指令。

寄存器`q2`和`q3`未初始化，可以在IRQ处理中作为临时存储。

以下所有指令都使用`custom0`操作码进行编码。在这些指令中，`f3`和`rs2`字段会被忽略。

请参见[firmware/custom_ops.S](firmware/custom_ops.S)中实现这些指令的GNU汇编宏。

请参见[firmware/start.S](firmware/start.S)中中断处理程序汇编包装器的示例实现，和[firmware/irq.c](firmware/irq.c)中实际的中断处理程序。

#### getq rd, qs

该指令将q寄存器中的值复制到一个通用寄存器中。

    0000000 ----- 000XX --- XXXXX 0001011
    f7      rs2   qs    f3  rd    opcode

示例：

    getq x5, q2

#### setq qd, rs

该指令将一个通用寄存器的值复制到一个q寄存器中。

    0000001 ----- XXXXX --- 000XX 0001011
    f7      rs2   rs    f3  qd    opcode

示例：

    setq q2, x5

#### retirq

从中断返回。该指令将`q0`中的值复制到程序计数器，并重新启用中断。

    0000010 ----- 00000 --- 00000 0001011
    f7      rs2   rs    f3  rd    opcode

示例：

    retirq

#### maskirq

“IRQ掩码”寄存器包含一个被掩码（禁用）的中断的位掩码。该指令写入新值到IRQ掩码寄存器，并读取旧值。

    0000011 ----- XXXXX --- XXXXX 0001011
    f7      rs2   rs    f3  rd    opcode

示例：

    maskirq x1, x2

处理器开始时所有中断都是禁用的。

在非法指令或总线错误被禁用的情况下，会导致处理器停止。

#### waitirq

暂停执行，直到某个中断变为待处理状态。待处理IRQ的位掩码会被写入到`rd`。

    0000100 ----- 00000 --- XXXXX 0001011
    f7      rs2   rs    f3  rd    opcode

示例：

    waitirq x1

#### timer

将计时器计数器重置为一个新值。计数器倒计时，直到从1到0转换时触发定时器中断。将计数器设置为零禁用定时器。计数器的旧值会被写入到`rd`。

    0000101 ----- XXXXX --- XXXXX 0001011
    f7      rs2   rs    f3  rd    opcode

示例：

    timer x1, x2


构建纯RV32I工具链
-------------------------------

简要说明：运行以下命令构建完整的工具链：

    make download-tools
    make -j$(nproc) build-tools

[riscv-tools](https://github.com/riscv/riscv-tools)构建脚本中的默认设置将构建一个编译器、汇编器和链接器，可以支持任何RISC-V ISA，但库是为RV32G和RV64G目标构建的。按照以下说明，构建一个完整的工具链（包括库），以支持纯RV32I CPU。

以下命令将构建RISC-V GNU工具链和库，并安装到`/opt/riscv32i`：

    # 需要的Ubuntu包：
    sudo apt-get install autoconf automake autotools-dev curl libmpc-dev \
            libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
	    gperf libtool patchutils bc zlib1g-dev git libexpat1-dev

    sudo mkdir /opt/riscv32i
    sudo chown $USER /opt/riscv32i

    git clone https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-rv32i
    cd riscv-gnu-toolchain-rv32i
    git checkout 411d134
    git submodule update --init --recursive

    mkdir build; cd build
    ../configure --with-arch=rv32i --prefix=/opt/riscv32i
    make -j$(nproc)

这些命令的工具将使用`riscv32-unknown-elf-`前缀，这样就可以与常规的riscv-tools（它们使用默认的`riscv64-unknown-elf-`前缀）并行安装。

或者，您可以直接使用PicoRV32的Makefile中的以下make目标，来构建一个`RV32I[M][C]`工具链。仍然需要按照上面描述的步骤安装所有先决条件。然后，在PicoRV32源目录中运行以下任意命令：

| 命令                                   | 安装目录        | ISA      |
|:-------------------------------------- |:--------------- |:-------- |
| `make -j$(nproc) build-riscv32i-tools` | `/opt/riscv32i/`| `RV32I`  |
| `make -j$(nproc) build-riscv32ic-tools`| `/opt/riscv32ic/`| `RV32IC`|
| `make -j$(nproc) build-risc

v32im-tools`| `/opt/riscv32im/`| `RV32IM`|
| `make -j$(nproc) build-riscv32imc-tools`| `/opt/riscv32imc/`| `RV32IMC`|

或者，简单地运行`make -j$(nproc) build-tools`来构建并安装所有四个工具链。

默认情况下，调用这些make目标时会（重新）下载工具链源代码。运行`make download-tools`以将源代码下载到`/var/cache/distfiles/`一次。

*注意：这些说明适用于riscv-gnu-toolchain的git版本411d134（2018-02-14）。*


使用newlib为PicoRV32链接二进制文件
-----------------------------------------

这些工具链（参见上一部分的安装说明）附带一个版本的
newlib C标准库。

使用链接脚本[firmware/riscv.ld](firmware/riscv.ld)来链接二进制文件
与newlib库。使用此链接脚本将创建一个其入口点位于0x10000的二进制文件。（默认链接脚本没有静态
入口点，因此需要一个能够在加载程序时确定入口点的ELF加载器。）

Newlib附带了一些syscall存根。您需要提供自己实现这些syscall的代码并将其与程序链接，
以覆盖newlib中的默认存根。请参见`syscalls.c`在[脚本/cxxdemo/](scripts/cxxdemo/)
中的示例，了解如何操作。


评估：在Xilinx 7系列FPGA上的时序和利用率
-----------------------------------------------------------

以下评估使用Vivado 2017.3进行。

#### 在Xilinx 7系列FPGA上的时序

启用`TWO_CYCLE_ALU`的`picorv32_axi`模块已在所有速度等级的
Xilinx Artix-7T、Kintex-7T、Virtex-7T、Kintex UltraScale和Virtex UltraScale器件上进行了放置和布线。
使用二分查找来确定设计满足时序的最短时钟周期。

参见[scripts/vivado/](scripts/vivado/)中的`make table.txt`。

| 设备                     | 设备               | 速度等级 | 时钟周期（频率） |
|:------------------------- |:-------------------|:--------:| ----------------:|
| Xilinx Kintex-7T          | xc7k70t-fbg676-2    | -2       | 2.4 ns (416 MHz) |
| Xilinx Kintex-7T          | xc7k70t-fbg676-3    | -3       | 2.2 ns (454 MHz) |
| Xilinx Virtex-7T          | xc7v585t-ffg1761-2  | -2       | 2.3 ns (434 MHz) |
| Xilinx Virtex-7T          | xc7v585t-ffg1761-3  | -3       | 2.2 ns (454 MHz) |
| Xilinx Kintex UltraScale  | xcku035-fbva676-2-e | -2       | 2.0 ns (500 MHz) |
| Xilinx Kintex UltraScale  | xcku035-fbva676-3-e | -3       | 1.8 ns (555 MHz) |
| Xilinx Virtex UltraScale  | xcvu065-ffvc1517-2-e| -2       | 2.1 ns (476 MHz) |
| Xilinx Virtex UltraScale  | xcvu065-ffvc1517-3-e| -3       | 2.0 ns (500 MHz) |
| Xilinx Kintex UltraScale+ | xcku3p-ffva676-2-e  | -2       | 1.4 ns (714 MHz) |
| Xilinx Kintex UltraScale+ | xcku3p-ffva676-3-e  | -3       | 1.3 ns (769 MHz) |
| Xilinx Virtex UltraScale+ | xcvu3p-ffvc1517-2-e | -2       | 1.5 ns (666 MHz) |
| Xilinx Virtex UltraScale+ | xcvu3p-ffvc1517-3-e | -3       | 1.4 ns (714 MHz) |

#### 在Xilinx 7系列FPGA上的资源利用率

以下表格列出了在资源优化综合下三种核心的资源利用情况：

- **PicoRV32（小型）**：`picorv32`模块，不包括计数器指令，
  不使用两级移位，外部锁存`mem_rdata`，且不捕获未对齐的内存访问和非法指令。

- **PicoRV32（常规）**：`picorv32`模块的默认配置。

- **PicoRV32（大型）**：`picorv32`模块，启用了PCPI、IRQ、MUL、
  DIV、BARREL_SHIFTER和COMPRESSED_ISA特性。

参见[scripts/vivado/](scripts/vivado/)中的`make area`。

| 核变体               | Slice LUTs | LUT作为内存 | Slice寄存器 |
|:-------------------- | ----------:| -----------:| -----------:|
| PicoRV32（小型）     |        761 |            48 |            442 |
| PicoRV32（常规）     |        917 |            48 |            583 |
| PicoRV32（大型）     |       2019 |            88 |           1085 |