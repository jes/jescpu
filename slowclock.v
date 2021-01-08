module slowclock (clk_in, clk_out);
    input clk_in;
    output clk_out;
    reg [31:0] count;

    always @ (negedge clk_in) begin
        count <= count + 1;
        if (count >= 7) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
    end
endmodule
