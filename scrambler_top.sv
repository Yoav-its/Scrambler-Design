module scrambler_top(
input nreset,
input valid,
input clk,
input [15:0] data_in,
output valid_out,
output [63:0] data_out
);

wire clk_out_for_clockDivider;
wire [15:0]data_out_input_sampler_16bit;
wire valid_input_sampler;
wire nreset_input_sampler;
wire [15:0]data_out_16bit;
wire valid_out_16bit;
wire valid_out_bit16to64;
wire [63:0]data_out_bit16to64;

    input_sampler input_sampler_1(
            .clk(clk_out_for_clockDivider),
            .nreset(nreset),
            .valid(valid),
            .data_in_16bit(data_in),
            .data_in_64bit(),
            .data_sampled_16bit(data_out_input_sampler_16bit),
            .data_sampled_64bit(),
            .valid_sampled(valid_input_sampler),
            .nreset_sampled(nreset_input_sampler)
        );

    clock_divider clock_divider_1(
        .clk_in(clk),
        .nreset(nreset),
        .clk_out(clk_out_for_clockDivider)
    );    

    scrambler_16bit scrambler_16bit_1(
        .clk(clk_out_for_clockDivider),
        .valid(valid_input_sampler),
        .nreset(nreset),
        .data_in(data_out_input_sampler_16bit),
        .data_out_64bit(),
        .data_out_48bit(),
        .data_out_32bit(),
        .data_out_16bit(data_out_16bit),
        .valid_out(valid_out_16bit)
    );

    bit16to64 bit16to64_1(
        .nreset(nreset),
        .valid_in(valid_out_16bit),
        .clk(clk_out_for_clockDivider),
        .data_in(data_out_16bit),
        .valid_out(valid_out_bit16to64),
        .data_out(data_out_bit16to64)
    );

    scrambler_64bit scrambler_64bit_1(
        .clk(clk_out_for_clockDivider),
        .valid(valid_out_bit16to64),
        .nreset(nreset),
        .data_in(data_out_bit16to64),
        .data_out_64bit(data_out),
        .data_out_48bit(),
        .data_out_32bit(),
        .valid_out(valid_out)
    );
endmodule