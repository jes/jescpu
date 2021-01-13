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
    reg wr_enable;
    reg [7:0] addr_bus;
    wire [7:0] rdata;
    reg [7:0] wdata;
    ram memory (clk, wr_enable, addr_bus, wdata, rdata);

    /* CPU state */
    reg [7:0] pc = 0;
    reg [7:0] opcode;
    reg [7:0] operand1;
    reg [7:0] operand2;
    reg [7:0] value1;
    reg [7:0] value2;
    parameter prefetch=0, opcode_fetch=1, op1_fetch=2, op2_fetch=3, indirect1_fetch=4, indirect2_fetch=5, execute=6, wait=7, halt=128;
    parameter NOP=0, COPY=1, ADD=2, SUB=3, XOR=4, AND=5, OR=6, NOT=7, JMP=8, JZ=9, OUT=10, IN=11, NUMOPS=12;
    reg [7:0] state = prefetch;
    reg [7:0] nextstate;
    reg [31:0] waittime = 1;
    reg [7:0] out0;

    parameter WAITCYCLES=1;

    always @ (posedge clk) begin
        leds1 <= ~out0;
        leds2 <= ~opcode;
        leds3 <= ~state;
        leds4 <= ~pc;

        case (state)
            wait: begin
                /* Not entirely sure what is going on here. If WAITCYCLES is 1,
                   or above 22, then everything works, otherwise it sometimes
                   works fine, and sometimes halts almost immediately, seemingly
                   at random.

                    WAITCYCLES | Behaviour
                             1 | Always works
                          2-22 | Sometimes works, sometimes halts in various states
                           23+ | Always works
                 */
                if (waittime >= WAITCYCLES) begin
                    state <= nextstate;
                    waittime <= 1;
                end else begin
                    waittime <= waittime + 1;
                end
            end

            prefetch: begin
                addr_bus <= pc;
                wr_enable <= 0;
                state <= wait;
                nextstate <= opcode_fetch;
            end

            opcode_fetch: begin
                opcode <= rdata;
                /* check rdata instead of opcode because opcode isn't assigned until the
                   end of this clock tick */
                if (rdata == NOP) begin
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+1;
                end else if (rdata < NUMOPS) begin
                    addr_bus <= pc+1;
                    state <= wait;
                    nextstate <= op1_fetch;
                end else begin
                    state <= halt + state;
                end
            end

            op1_fetch: begin
                operand1 <= rdata;
                if (opcode == NOT) begin
                    /* use rdata instead of operand1 because operand1 isn't assigned until the
                       end of this clock tick */
                    addr_bus <= rdata;
                    state <= wait;
                    nextstate <= indirect1_fetch;
                end else if (opcode == JMP) begin
                    state <= wait;
                    nextstate <= execute;
                end else begin
                    addr_bus <= pc+2;
                    state <= wait;
                    nextstate <= op2_fetch;
                end
            end

            op2_fetch: begin
                operand2 <= rdata;
                if (opcode == COPY) begin
                    /* use rdata instead of operand2 because operand2 isn't assigned until the
                       end of this clock tick */
                    addr_bus <= rdata;
                    state <= wait;
                    nextstate <= indirect2_fetch;
                end else if (opcode == ADD || opcode == SUB || opcode == XOR || opcode == AND || opcode == OR || opcode == JZ || opcode == OUT) begin
                    addr_bus <= operand1;
                    state <= wait;
                    nextstate <= indirect1_fetch;
                end else if (opcode == IN) begin
                    state <= wait;
                    nextstate <= execute;
                end else begin
                    state <= halt + state;
                end
            end

            indirect1_fetch: begin
                value1 <= rdata;
                if (opcode == NOT || opcode == JZ || opcode == OUT) begin
                    state <= wait;
                    nextstate <= execute;
                end else begin
                    addr_bus <= operand2;
                    state <= wait;
                    nextstate <= indirect2_fetch;
                end
            end

            indirect2_fetch: begin
                value2 <= rdata;
                state <= wait;
                nextstate <= execute;
            end

            execute: begin
                if (opcode == COPY) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= value2;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == ADD) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= value1 + value2;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == SUB) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= value1 - value2;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == XOR) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= value1 ^ value2;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == AND) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= value1 & value2;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == OR) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= value1 | value2;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == NOT) begin
                    addr_bus <= operand1;
                    wr_enable <= 1;
                    wdata <= ~value1;
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+2;
                end else if (opcode == JMP) begin
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= operand1;
                end else if (opcode == JZ) begin
                    if (value1 == 0) begin
                        state <= wait;
                        nextstate <= prefetch;
                        pc <= operand2;
                    end else begin
                        state <= wait;
                        nextstate <= prefetch;
                        pc <= pc+3;
                    end
                end else if (opcode == OUT) begin
                    if (operand2 == 0) begin
                        out0 <= value1;
                    end
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else if (opcode == IN) begin
                    state <= wait;
                    nextstate <= prefetch;
                    pc <= pc+3;
                end else begin
                    state <= halt + state;
                end
            end
        endcase
    end
endmodule
