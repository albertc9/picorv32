// ============================================================================
//  PicoSoC minimal top‑level (v2) for 升腾/野火 Mini ‑ Artix‑7 XC7A100T‑FGG484
//  ‑ 将板载 QSPI Flash 的 CLK 复用到 FPGA 专用 CCLK(L12)；
//    必须通过 STARTUPE2.USRCCLKO 输出时钟，故 flash_clk 不再是顶层 IO。
//  ‑ 只公开 9 根外部引脚：
//        clk_50m, rst_btn_n, ser_rx/tx, flash_csb, flash_io[3:0]
//    其余片上总线/中断/PCPI 均在此封装内“吃掉”。
// ============================================================================

`timescale 1ns / 1ps

module picosoc_top (
    // ─── 系统时钟 / 复位 ───────────────────────────────────────────────
    input  wire clk_50m,      // 50 MHz 板载晶振
    input  wire rst_btn_n,    // 按键，低有效

    // ─── UART -----------------------------------------------------------
    input  wire ser_rx,
    output wire ser_tx,

    // ─── QSPI Flash -----------------------------------------------------
    output wire flash_csb,
    inout  wire flash_io0,
    inout  wire flash_io1,
    inout  wire flash_io2,
    inout  wire flash_io3
);

    // 同步复位（直接送到 SoC，内部自行两级同步）
    wire resetn = rst_btn_n;

    // ────────────────────────────────────────────────────────────────────
    //  QSPI IO[3:0] -> IOBUF
    // ────────────────────────────────────────────────────────────────────
    wire io0_o, io0_i, io0_oe;
    wire io1_o, io1_i, io1_oe;
    wire io2_o, io2_i, io2_oe;
    wire io3_o, io3_i, io3_oe;

    IOBUF iobuf_io0 (.IO(flash_io0), .I(io0_o), .O(io0_i), .T(~io0_oe));
    IOBUF iobuf_io1 (.IO(flash_io1), .I(io1_o), .O(io1_i), .T(~io1_oe));
    IOBUF iobuf_io2 (.IO(flash_io2), .I(io2_o), .O(io2_i), .T(~io2_oe));
    IOBUF iobuf_io3 (.IO(flash_io3), .I(io3_o), .O(io3_i), .T(~io3_oe));

    // ────────────────────────────────────────────────────────────────────
    //  内部 SPI 时钟，稍后通过 STARTUPE2 -> CCLK(L12)
    // ────────────────────────────────────────────────────────────────────
    wire spi_clk_int;

    // ────────────────────────────────────────────────────────────────────
    //  PicoSoC 实例化
    // ────────────────────────────────────────────────────────────────────
    picosoc soc (
        .clk          (clk_50m),
        .resetn       (resetn),

        // UART
        .ser_tx       (ser_tx),
        .ser_rx       (ser_rx),

        // QSPI
        .flash_csb    (flash_csb),
        .flash_clk    (spi_clk_int),   // 连接内部时钟线

        .flash_io0_do (io0_o), .flash_io0_di(io0_i), .flash_io0_oe(io0_oe),
        .flash_io1_do (io1_o), .flash_io1_di(io1_i), .flash_io1_oe(io1_oe),
        .flash_io2_do (io2_o), .flash_io2_di(io2_i), .flash_io2_oe(io2_oe),
        .flash_io3_do (io3_o), .flash_io3_di(io3_i), .flash_io3_oe(io3_oe),

        // 未使用外部中断
        .irq_5        (1'b0),
        .irq_6        (1'b0),
        .irq_7        (1'b0),

        // 片上外设总线：全部忽略
        .iomem_valid  (), .iomem_addr(), .iomem_wdata(),
        .iomem_wstrb  (), .iomem_rdata(), .iomem_ready()
    );

    // ────────────────────────────────────────────────────────────────────
    //  STARTUPE2: 将 spi_clk_int 借道 CCLK(L12) 输出到 Flash
    // ────────────────────────────────────────────────────────────────────
    STARTUPE2 #(
        .PROG_USR("FALSE"),       // 保持默认
        .SIM_CCLK_FREQ(0.0)       // 仅仿真用
    ) startupe2_inst (
        .USRCCLKO (spi_clk_int),  // 用户时钟 -> CCLK
        .USRCCLKTS(1'b0),         // 0 = 使能输出
        .CFGCLK   (),
        .CFGMCLK  (),
        .EOS      (),
        .PREQ     (),
        .CLK      (1'b0),
        .GSR      (1'b0),
        .GTS      (1'b0),
        .KEYCLEARB(1'b1),
        .PACK     (1'b0),
        .USRDONEO (1'b1),
        .USRDONETS(1'b1)
    );

endmodule