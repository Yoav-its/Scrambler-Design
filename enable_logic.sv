module enable_logic(
    input valid,
    input Sum,
    input Cout,
    output en0,en1,en2,en3,en_counter
);

assign en0=valid & (~Sum) & (~Cout);
assign en1=valid & (Sum) & (~Cout);
assign en2=valid & (~Sum) & (Cout);
assign en3=valid & (Sum) & (Cout);

assign en_counter=valid;

endmodule