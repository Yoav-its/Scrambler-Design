`timescale 1ns / 1ps

module scrambler_tb; // no ports

    // defining inputs
    reg nreset;
    reg valid;

    //InputSampler- DUT2
    reg [15:0]data_in_input_sampler_16bit;
    reg [63:0]data_in_input_sampler_64bit;    
    wire nreset_input_sampler;
    wire valid_input_sampler;
    wire [15:0]data_out_input_sampler_16bit;
    wire [63:0]data_out_input_sampler_64bit;
    

    //scrambler_64bit -DUT0
    reg [63:0] inputs_64bit [0:999];
    reg [63:0] expected_output_64bit [0:999];
    reg [63:0] golden_lfsr_bits_64bit [0:999];//for every input the lfsr is calculated-1000 inputs,16 lfsr bits each
    wire [63:0] data_out_64bit;
    //probing for DUT0
    wire [63:0] xor_logic_output_DUT0;
    assign xor_logic_output_DUT0=DUT0.xor_logic_output;    
    // Golden model state: [0]=s1 .. [6]=s7
    reg  [7:1]  golden_shifter;
    reg         golden_bit;
    reg  [63:0] golden_out_64bit;
    integer pass_count, fail_count, i,j;
    integer seed;
    
    //scrambler-16bit- DUT1
    reg [15:0] inputs_16bit [0:999];
    reg [15:0] expected_output_16bit [0:999];
    reg [15:0] golden_lfsr_bits_16bit [0:999];//for every input the lfsr is calculated-1000 inputs,16 lfsr bits each
    reg  [15:0] golden_out_16bit;
    wire [15:0] data_out_16bit;
    //probing for DUT1
    wire [15:0] xor_logic_output_DUT1;
    assign xor_logic_output_DUT1=DUT1.xor_logic_output;
    
    //clockDivider TB input and output
    reg clk;
    wire clk_out_for_clockDivider;



    input_sampler DUT2(
        .clk(clk_out_for_clockDivider),
        .nreset(nreset),
        .valid(valid),
        .data_in_16bit(data_in_input_sampler_16bit),
        .data_in_64bit(data_in_input_sampler_64bit),
        .data_sampled_16bit(data_out_input_sampler_16bit),
        .data_sampled_64bit(data_out_input_sampler_64bit),
        .valid_sampled(valid_input_sampler),
        .nreset_sampled(nreset_input_sampler)
    );

    clock_divider DUT3(
        .clk_in(clk),
        .nreset(nreset),
        .clk_out(clk_out_for_clockDivider)
    );    

    scrambler_64bit DUT0(
        .clk(clk_out_for_clockDivider),
        .valid(valid_input_sampler),
        .nreset(nreset),
        .data_in(data_out_input_sampler_64bit),
        .data_out_64bit(data_out_64bit),
        .data_out_48bit(),
        .data_out_32bit()
    );

    scrambler_16bit DUT1(
        .clk(clk_out_for_clockDivider),
        .valid(valid_input_sampler),
        .nreset(nreset),
        .data_in(data_out_input_sampler_16bit),
        .data_out_64bit(),
        .data_out_48bit(),
        .data_out_32bit(),
        .data_out_16bit(data_out_16bit)
    );

    always #5 clk=~clk;

    initial begin
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);

        clk=0;
        pass_count = 0;
        fail_count = 0;

        nreset=0;
        #20;
        nreset=1'b1;
        valid=0;
        @(posedge clk_out_for_clockDivider);  

        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);

        //Phase 1:generating 1000 inputs,and calculating expected output
        golden_shifter = 7'b1111111; // same as DUT async-reset value
        for(i=0;i<1000;i=i+1) begin 
            inputs_64bit[i]=$random(seed) & 64'hFFFFFFFFFFFFFFFF;
            golden_out_64bit=0;
            for (j=0;j<64;j=j+1) begin
                golden_bit=golden_shifter[4]^ golden_shifter[7];//calculate the next lfsr
                golden_lfsr_bits_64bit[i][j]=golden_bit;// the current lfsr is being stored
                golden_out_64bit[j]=golden_bit^inputs_64bit[i][j];
                golden_shifter={golden_shifter[6:1],golden_bit};
            end
            //taking the golden out fronm the previous for loop(16bit) and inserting it inside row i,every row holds 16bit
            expected_output_64bit[i]=golden_out_64bit;
        end
        #50;
        for(i=0;i<1000;i=i+1) begin
            //sampling the input into the inputSampler and from there to the DUT0            
            data_in_input_sampler_64bit=inputs_64bit[i];
            valid=1'b1;
            @(posedge clk_out_for_clockDivider);
            #1;
            //comparing expected data out to the actual data out
            if(data_out_64bit==expected_output_64bit[i]) begin
            pass_count=pass_count+1;
            end
            else begin
                $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_64bit[i],data_out_64bit);
                fail_count=fail_count+1;
            end
            if(xor_logic_output_DUT0!= golden_lfsr_bits_64bit[i])
            $display("Cycle %4d: LFSR MISMATCH (sequential=%04X, parallel=%04X)",i, golden_lfsr_bits_64bit[i], DUT0.xor_logic_output);
        end
        #20;
        $display("\n%0d PASSED, %0d FAILED", pass_count,fail_count);


        //Now for the 16bit scrambler
        nreset=0;
        #20;
        nreset=1'b1;
        valid=0;
        @(posedge clk_out_for_clockDivider);  
        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);
        //Phase 1:generating 1000 inputs,and calculating expected output
        golden_shifter = 7'b1111111; // same as DUT async-reset value
        for(i=0;i<1000;i=i+1) begin 
            inputs_16bit[i]=$random(seed) & 16'hFFFF;
            golden_out_16bit=0;
            for (j=0;j<16;j=j+1) begin
                golden_bit=golden_shifter[4]^ golden_shifter[7];//calculate the next lfsr
                golden_lfsr_bits_16bit[i][j]=golden_bit;// the current lfsr is being stored
                golden_out_16bit[j]=golden_bit^inputs_16bit[i][j];
                golden_shifter={golden_shifter[6:1],golden_bit};
            end
            //taking the golden out fronm the previous for loop(16bit) and inserting it inside row i,every row holds 16bit
            expected_output_16bit[i]=golden_out_16bit;
        end
        #50;
        for(i=0;i<1000;i=i+1) begin
            //sampling the input into the inputSampler and from there to the DUT1
            data_in_input_sampler_16bit=inputs_16bit[i];
            valid=1'b1;
            @(posedge clk_out_for_clockDivider);
            #1;
            //comparing expected data out to the actual data out
            if(data_out_16bit==expected_output_16bit[i]) begin
            pass_count=pass_count+1;
            end
            else begin
                $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_16bit[i],data_out_16bit);
                fail_count=fail_count+1;
            end
            if(xor_logic_output_DUT1!= golden_lfsr_bits_16bit[i])
            $display("Cycle %4d: LFSR MISMATCH (sequential=%04X, parallel=%04X)",i, golden_lfsr_bits_16bit[i], DUT1.xor_logic_output);
        end
        #20;
        $display("\n%0d PASSED, %0d FAILED", pass_count,fail_count);
        $finish;  
    end

endmodule