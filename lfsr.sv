module lfsr(
    input clk,
    input nreset,
    input [7:1] in_data,
    output logic [7:1] shifter_output
);



always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
    shifter_output<=7'b1111111;
    end
    else begin
    shifter_output<=in_data;
    end 
end

endmodule