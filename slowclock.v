module slowclock (clk_in, clk_out);
    input clk_in;
    output reg clk_out;
    reg [31:0] count;

    always @ (posedge clk_in) begin
        if (count >= 8) begin
            count <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end
endmodule
