module scrambler_32bit(
    input valid,
    input clk,
    input nreset,
    input [31:0] data_in,
    output [31:0] data_out
);

wire [7:1]mux_output; //the wire that goes inside the lfsr
wire [7:1] shifter_output; //this wire goes from outside the shifters inside the xor_logic
wire [31:0] xor_logic_output; //this wire goes from outside the xor_logic to the output_xor,delivering all the 64 lfsr's
wire [7:1]current_stage;
wire [7:1]next_stage;


//module wires
wire [15:0]lfsr1;
wire [15:0]lfsr2;

//the reason for the explicitness of next stage is that
// bcz for current stage the input stay the same and shouldnt be reversed as the new stage should
assign current_stage=shifter_output;
assign next_stage[1]=xor_logic_output[15];
assign next_stage[2]=xor_logic_output[14];
assign next_stage[3]=xor_logic_output[13];
assign next_stage[4]=xor_logic_output[12];
assign next_stage[5]=xor_logic_output[11];
assign next_stage[6]=xor_logic_output[10];
assign next_stage[7]=xor_logic_output[9];

assign mux_output=valid ? next_stage : current_stage; 

assign data_out[31:0]=xor_logic_output[31:0] ^data_in[31:0]; //output xor

xor_logic xor_logic1(
    .shifter_output(shifter_output),
    .lfsr(lfsr1)
);

xor_logic xor_logic2(
    .shifter_output({lfsr1[9],lfsr1[10],lfsr1[11],lfsr1[12],lfsr1[13],lfsr1[14],lfsr1[15]}),
    .lfsr(lfsr2)
);

lfsr lfsr_machine(
    .clk(clk),
    .nreset(nreset),
    .in_data(mux_output),
    .shifter_output(shifter_output)
);

assign xor_logic_output[15:0]=lfsr1[15:0];
assign xor_logic_output[31:16]=lfsr2[15:0];


endmodule

