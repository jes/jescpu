// https://stackoverflow.com/a/41509289

module ram (
    input clk,
    input wr_enable,
    input [7:0] addr,
    input [7:0] wdata,
    output wire [7:0] rdata,
);
    reg [7:0] mem [0:255];

    initial begin
        $readmemh("memcycle.hex", mem);
    end

    always @ (posedge clk) begin
        if (wr_enable) mem[addr] <= wdata;
        rdata <= mem[addr];
    end
endmodule
