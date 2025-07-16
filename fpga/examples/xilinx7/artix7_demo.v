module artix7_demo (
    input clk100,           // 100MHz系统时钟
    input rst_n,            // 复位信号，低电平有效
    
    // UART接口
    output uart_tx,
    input uart_rx,
    
    // SPI Flash接口
    output flash_cs_n,
    output flash_clk,
    inout flash_mosi,
    inout flash_miso,
    inout flash_wp_n,
    inout flash_hold_n,
    
    // LED指示灯
    output [7:0] leds,
    
    // 按钮
    input [3:0] buttons,
    
    // 开关
    input [7:0] switches
);

    // 时钟和复位
    wire clk;
    wire resetn;
    
    // 时钟管理
    assign clk = clk100;
    assign resetn = rst_n;
    
    // 中断信号
    wire [31:0] irq;
    assign irq = {28'h0, buttons};
    
    // 陷阱信号
    wire trap;
    
    // PicoRV32 SoC实例
    picorv32_soc soc (
        .clk(clk),
        .resetn(resetn),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx),
        .flash_csb(flash_cs_n),
        .flash_clk(flash_clk),
        .flash_io0(flash_mosi),
        .flash_io1(flash_miso),
        .flash_io2(flash_wp_n),
        .flash_io3(flash_hold_n),
        .leds(leds),
        .buttons(buttons),
        .switches(switches),
        .irq(irq),
        .trap(trap)
    );

endmodule 