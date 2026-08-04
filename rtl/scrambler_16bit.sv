module scrambler_16bit(
    input valid,
    input clk,
    input nreset,
    input [15:0] data_in,
    output [63:0] data_out_64bit,
    output [47:0] data_out_48bit,
    output [31:0] data_out_32bit,
    output [15:0] data_out_16bit
);

wire [7:1]mux_output; //the wire that goes inside the lfsr
wire [7:1] shifter_output; //this wire goes from outside the shifters inside the xor_logic
wire [15:0] xor_logic_output; //this wire goes from outside the xor_logic to the output_xor,delivering all the 64 lfsr's
//wire [31:0] xor_logic_output_test; // just like the regular one,but for tests.
wire [7:1]current_stage;
wire [7:1]next_stage;


//module wires
wire [15:0]lfsr1;
wire [15:0]lfsr2;
wire [15:0]lfsr3;
wire [15:0]lfsr4;
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

//my test for each output
assign data_out_16bit[15:0]=xor_logic_output[15:0] ^data_in[15:0]; //output xor



xor_logic xor_logic1(
    .shifter_output(shifter_output),
    .lfsr(lfsr1)
);

xor_logic xor_logic2(
    .shifter_output({lfsr1[9],lfsr1[10],lfsr1[11],lfsr1[12],lfsr1[13],lfsr1[14],lfsr1[15]}),
    .lfsr(lfsr2)
);

xor_logic xor_logic3(
    .shifter_output({lfsr2[9],lfsr2[10],lfsr2[11],lfsr2[12],lfsr2[13],lfsr2[14],lfsr2[15]}),
    .lfsr(lfsr3)
);

xor_logic xor_logic4(
    .shifter_output({lfsr3[9],lfsr3[10],lfsr3[11],lfsr3[12],lfsr3[13],lfsr3[14],lfsr3[15]}),
    .lfsr(lfsr4)
);

lfsr lfsr_machine(
    .clk(clk),
    .nreset(nreset),
    .in_data(mux_output),
    .shifter_output(shifter_output)
);

assign xor_logic_output[15:0]=lfsr1[15:0];
//assign xor_logic_output[31:16]=lfsr2[15:0];
//assign xor_logic_output[47:32]=lfsr3[15:0];
//assign xor_logic_output[63:48]=lfsr4[15:0];


 
endmodule






/*


module scrambler_16bit(
    input [15:0] data_in,
    input clk,
    input valid,
    input nreset,
    output [15:0] data_out
);


//connecting between lfsr s output to xor_logic s input 
wire [7:1]shifter_output;
//connecting between the xor_logic cloud([15:0]lfsr) to the output xor 
wire [15:0]lfsr_output;
//connecting between the output of the mux(input of the lfsr) to the input of the mux
wire [7:1]lfsr_data_in;
wire [7:1]mux_input;
//from the output of the xor logic to the outside of the mux
assign mux_input[1] = lfsr_output[15];
assign mux_input[2] = lfsr_output[14];
assign mux_input[3] = lfsr_output[13];
assign mux_input[4] = lfsr_output[12];
assign mux_input[5] = lfsr_output[11];
assign mux_input[6] = lfsr_output[10];
assign mux_input[7] = lfsr_output[9];

//Creating validation mux for input data
assign lfsr_data_in= valid? mux_input : shifter_output ;
//creating the output xor 
assign data_out=lfsr_output ^ data_in;


xor_logic xor_logic1(
    .shifter_output(shifter_output),
    .lfsr(lfsr_output)
);

lfsr lfsr1(
    .clk(clk),
    .nreset(nreset),
    .in_data(lfsr_data_in),
    .shifter_output(shifter_output)
);



endmodule

*/