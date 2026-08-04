module clock_divider(
    input clk_in,
    input nreset,
    output reg clk_out
);

always @(posedge clk_in or negedge nreset) begin
    if(!nreset) begin
        clk_out<=1'b0;
    end
    else begin
        clk_out<=~clk_out;
    end
end





endmodule