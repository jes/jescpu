`include "ledscan.v"
`include "ram.v"

module top(clk,led1,led2,led3,led4,led5,led6,led7,led8,lcol1,lcol2,lcol3,lcol4);
    input clk;
    output led1;
    output led2;
    output led3;
    output led4;
    output led5;
    output led6;
    output led7;
    output led8;
    output lcol1;
    output lcol2;
    output lcol3;
    output lcol4;

    /* LED output */
    reg [7:0] leds1;
    reg [7:0] leds2;
    reg [7:0] leds3;
    reg [7:0] leds4;
	wire [7:0] leds;
	wire [3:0] lcol;
	assign { led8, led7, led6, led5, led4, led3, led2, led1 } = leds[7:0];
	assign { lcol4, lcol3, lcol2, lcol1 } = lcol[3:0];
    LedScan scan (
        .clk12MHz(clk),
        .leds1(leds1),
        .leds2(leds2),
        .leds3(leds3),
        .leds4(leds4),
        .leds(leds),
        .lcol(lcol)
    );

    /* RAM */
    wire mem_reset;
    wire wr_enable;
    wire [7:0] addr_bus;
    wire [7:0] rdata;
    wire [7:0] wdata;
    wire mem_ready;
    ram memory (clk, wr_enable, addr_bus, rdata, wdata);

    /* CPU state */
    reg [7:0] pc;
    reg [7:0] opcode;
    reg [7:0] operand1;
    reg [7:0] operand2;
    parameter fetch1=1, fetch2=2, fetch3=3, compute=4, store=5;
    reg [2:0] state;

    always @ (posedge clk) begin
        mem_reset <= 0;
        addr_bus <= 0;
        wr_enable <= 1;
        wdata <= 8'b01010101;
        leds1 <= ~rdata;
        leds2 <= ~addr_bus;
        leds3 <= 8'hff;
        leds4 <= 8'hff;
    end
endmodule
