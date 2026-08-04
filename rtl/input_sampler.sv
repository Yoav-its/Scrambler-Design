module input_sampler(
    input clk,
    input nreset,
    input valid,
    input [15:0]data_in_16bit,
    input [63:0]data_in_64bit,
    output logic [63:0] data_sampled_64bit,
    output logic [15:0] data_sampled_16bit,
    output logic valid_sampled,
    output logic nreset_sampled 
);

always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
        data_sampled_16bit<=16'b0;
        data_sampled_64bit<=64'b0;
        valid_sampled<=1'b0;
        nreset_sampled<=1'b0;        
    end
    else begin
        data_sampled_16bit<=data_in_16bit;
        data_sampled_64bit<=data_in_64bit;
        valid_sampled<=valid;
        nreset_sampled<=nreset;
        
    end
end

endmodule