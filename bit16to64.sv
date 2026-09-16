module bit16to64 (
    input nreset,
    input valid_in,
    input clk,
    input [15:0] data_in,
    output reg valid_out,
    output reg [63:0] data_out
);

reg Sum;
reg Cout;
wire en0,en1,en2,en3;
wire Sum_next;
wire Cout_next;
wire en_counter;

wire [63:0] prev;
wire prev_sum;
wire prev_cout;
wire prev_valid_out;

wire [15:0]mux_en0;
wire [15:0]mux_en1;
wire [15:0]mux_en2;
wire [15:0]mux_en3;
wire mux_valid_out,mux_sum,mux_cout;
wire sum_next_mux;

enable_logic enable_logic1(
    .valid(valid_in),
    .Sum(Sum),
    .Cout(Cout),
    .en0(en0),
    .en1(en1),
    .en2(en2),
    .en3(en3),
    .en_counter(en_counter)
);
/*
counter counter1(
    .A(Sum),
    .B(Cout),
    .Sum_next(Sum_next),
    .Cout_next(Cout_next)
);
*/
//creating a mux for the counter
assign Sum_next=(~Sum);
assign Cout_next=Cout?(~Sum):Sum;
//assigning the previous states for all the FF
assign prev[15:0]=data_out[15:0];
assign prev[31:16]=data_out[31:16];
assign prev[47:32]=data_out[47:32];
assign prev[63:48]=data_out[63:48];

assign prev_sum=Sum;
assign prev_cout=Cout;
//assign prev_valid_out=valid_out;

//creating the mux for the inside of the FF-EN
assign mux_en0=en0 ? data_in: prev[15:0];
assign mux_en1=en1 ? data_in: prev[31:16];
assign mux_en2=en2 ? data_in: prev[47:32];
assign mux_en3=en3 ? data_in: prev[63:48];

assign mux_sum=en_counter? Sum_next: prev_sum;
assign mux_cout=en_counter? Cout_next: prev_cout;
//assign mux_valid_out=valid_in? en3: prev_valid_out;
assign mux_valid_out=valid_in? en3: 1'b0;
//[15:0] data out
always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
        data_out[15:0]<=16'b0;
    end
    else begin
        data_out[15:0]<=mux_en0;
        end
    end

//[31:16] data out
always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
        data_out[31:16]<=16'b0;
    end
    else begin
        data_out[31:16]<=mux_en1;
        end
    end

//[47:32] data out
always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
        data_out[47:32]<=16'b0;
    end
    else begin
        data_out[47:32]<=mux_en2;
        end
    end

//[63:48] data out
always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
        data_out[63:48]<=16'b0;
    end
    else begin
        data_out[63:48]<=mux_en3;
        end
    end


//counter FF-for the Sum and Cout
always @(posedge clk or negedge nreset) begin
    if(!nreset) begin
        Sum<=1'b0;
        Cout<=1'b0;
        valid_out<=1'b0;
    end
    else begin
            Sum<=mux_sum;
            Cout<=mux_cout;
            valid_out<=mux_valid_out;
        end
    end

endmodule