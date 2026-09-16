module xor_logic(
    input [7:1]shifter_output, //s1-s7
    output [15:0]lfsr //lfsr0-lfsr15
);

assign lfsr[0]=shifter_output[4]^shifter_output[7];
assign lfsr[1]=shifter_output[3]^shifter_output[6];
assign lfsr[2]=shifter_output[2]^shifter_output[5];
assign lfsr[3]=shifter_output[1]^shifter_output[4];
assign lfsr[4]=shifter_output[3]^shifter_output[4]^shifter_output[7];
assign lfsr[5]=shifter_output[2]^shifter_output[3]^shifter_output[6];
assign lfsr[6]=shifter_output[1]^shifter_output[2]^shifter_output[5];
assign lfsr[7]=shifter_output[1]^shifter_output[7];
assign lfsr[8]=shifter_output[4]^shifter_output[6]^shifter_output[7];
assign lfsr[9]=shifter_output[3]^shifter_output[5]^shifter_output[6];
assign lfsr[10]=shifter_output[2]^shifter_output[4]^shifter_output[5];
assign lfsr[11]=shifter_output[1]^shifter_output[3]^shifter_output[4];
assign lfsr[12]=shifter_output[2]^shifter_output[3]^shifter_output[4]^shifter_output[7];
assign lfsr[13]=shifter_output[1]^shifter_output[2]^shifter_output[3]^shifter_output[6];
assign lfsr[14]=shifter_output[1]^shifter_output[2]^shifter_output[4]^shifter_output[5]^shifter_output[7];
assign lfsr[15]=shifter_output[1]^shifter_output[3]^shifter_output[6]^shifter_output[7];

endmodule
