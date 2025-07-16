module picorv32_soc #(
    parameter integer MEM_WORDS = 256,
    parameter [31:0] STACKADDR = 32'h 0003_0000 + 4*MEM_WORDS,
    parameter [31:0] PROGADDR_RESET = 32'h 0010_0000,
    parameter [31:0] PROGADDR_IRQ = 32'h 0000_0010
) (
    input clk,
    input resetn,
    output uart_tx,
    input uart_rx,
    output flash_csb,
    output flash_clk,
    inout flash_io0,
    inout flash_io1,
    inout flash_io2,
    inout flash_io3,
    output [7:0] leds,
    input [3:0] buttons,
    input [7:0] switches,
    input [31:0] irq,
    output trap
);

    wire mem_valid, mem_instr, mem_ready;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    wire [3:0] mem_wstrb;

    picorv32 cpu (
        .clk(clk),
        .resetn(resetn),
        .trap(trap),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .irq(irq)
    );

    spimemio spimemio (
        .clk(clk),
        .resetn(resetn),
        .valid(mem_valid),
        .ready(mem_ready),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .wstrb(mem_wstrb),
        .rdata(mem_rdata),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .flash_io2(flash_io2),
        .flash_io3(flash_io3)
    );

    simpleuart uart (
        .clk(clk),
        .resetn(resetn),
        .ser_tx(uart_tx),
        .ser_rx(uart_rx),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb)
    );

    reg [7:0] led_reg;
    always @(posedge clk) begin
        if (!resetn) led_reg <= 8'h00;
        else if (mem_valid && mem_addr == 32'h03000000 && mem_wstrb[0])
            led_reg <= mem_wdata[7:0];
    end
    assign leds = led_reg;

endmodule 