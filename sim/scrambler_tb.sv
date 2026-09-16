`timescale 1ns / 1ps
//`define TEST_SCRAMBLER_16BIT
//`define TEST_BIT16TO64
//`define TEST_SCRAMBLER_64BIT
//`define MAKING_WAVEFORM_CONTINUES
//`define MAKING_WAVEFORM_DISCRETE
//`define MAKING_WAVEFORM_GENERAL_CASE
//`define TEST_SEED_IS_ZERO_16BIT
//`define TEST_SEED_IS_FULL_ONE_16TO16SCRAMBLER
//`define TEST_SEED_IS_FULL_ONE_64TO64SCRAMBLER
//`define TEST_FULL_TOP_END2END
//`define TEST_INCONTINOUS_VALID
`define CHECK_SCRAMBLER_TOP
module scrambler_tb; // no ports
parameter CLK_PERIOD=10;
    // defining inputs
    reg nreset;
    reg valid;

    //InputSampler- input_sampler_1
    reg [15:0]data_in_input_sampler_16bit;
    reg [63:0]data_in_input_sampler_64bit;    
    wire nreset_input_sampler;
    wire valid_input_sampler;
    wire [15:0]data_out_input_sampler_16bit;
    wire [63:0]data_out_input_sampler_64bit;


    //scrambler_64bit -scrambler_64bit_1
    reg [63:0] inputs_64bit [0:999];
    reg [63:0] expected_output_64bit [0:999];
    reg [63:0] golden_lfsr_bits_64bit [0:999];//for every input the lfsr is calculated-1000 inputs,16 lfsr bits each
    wire [63:0] data_out_64bit;
    //probing for scrambler_64bit_1
    wire [63:0] xor_logic_output_scrambler_64bit_1;
    assign xor_logic_output_scrambler_64bit_1=scrambler_64bit_1.xor_logic_output;    
    // Golden model state: [0]=s1 .. [6]=s7
    reg  [7:1]  golden_shifter;
    reg         golden_bit;
    reg  [63:0] golden_out_64bit;
    integer pass_count, fail_count,pass_count_bit16to64,fail_count_bit16to64, i,j;
    integer seed;
    
    //scrambler-16bit- scrambler_16bit_1
    reg [15:0] inputs_16bit [0:999];
    reg [15:0] expected_output_16bit [0:999];
    reg [15:0] golden_lfsr_bits_16bit [0:999];//for every input the lfsr is calculated-1000 inputs,16 lfsr bits each
    reg  [15:0] golden_out_16bit;
    wire [15:0] data_out_16bit;
    wire valid_out_16bit;
    wire valid_out_64bit;
    //probing for scrambler_16bit_1
    wire [15:0] xor_logic_output_scrambler_16bit_1;
    assign xor_logic_output_scrambler_16bit_1=scrambler_16bit_1.xor_logic_output;
    
    //clockDivider TB input and output
    reg clk;
    wire clk_out_for_clockDivider;

    //bit16to64- input and output
    wire valid_out_bit16to64;
    wire [63:0]data_out_bit16to64;
    reg valid_in_bit16to64;

 
    //bit16to64 golden module
    reg [63:0] expected_output_bit16to64 [0:249];
    reg [1:0] counter_16to64;
    
    input_sampler input_sampler_1(
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

    clock_divider clock_divider_1(
        .clk_in(clk),
        .nreset(nreset),
        .clk_out(clk_out_for_clockDivider)
    );    

    scrambler_64bit scrambler_64bit_1(
        .clk(clk_out_for_clockDivider),
        .valid(valid_out_bit16to64),
        .nreset(nreset),
        .data_in(data_out_bit16to64),
        .data_out_64bit(data_out_64bit),
        .data_out_48bit(),
        .data_out_32bit(),
        .valid_out(valid_out_64bit)
    );

    scrambler_64bit scrambler_64bit_2(
        .clk(clk_out_for_clockDivider),
        .valid(valid_out_64bit),
        .nreset(nreset),
        .data_in(data_out_64bit),
        .data_out_64bit(data_out_scrambler_64bit),
        .data_out_48bit(),
        .data_out_32bit(),
        .valid_out(valid_out_64bit_2)
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

    scrambler_16bit scrambler_16bit_2(
        .clk(clk_out_for_clockDivider),
        .valid(valid_out_16bit),
        .nreset(nreset),
        .data_in(data_out_16bit),
        .data_out_64bit(),
        .data_out_48bit(),
        .data_out_32bit(),
        .data_out_16bit(data_out_16bit_2),
        .valid_out(valid_out_16bit_2)
    );

    bit16to64 bit16to64_1(
        .nreset(nreset),
        .valid_in(valid_out_16bit),
        .clk(clk_out_for_clockDivider),
        .data_in(data_out_16bit),
        .valid_out(valid_out_bit16to64),
        .data_out(data_out_bit16to64)
    );

    bit16to64 bit16to64_2(
        .nreset(nreset),
        .valid_in(valid),
        .clk(clk_out_for_clockDivider),
        .data_in(data_in_bit16to64_2),
        .valid_out(valid_out_bit16to64_2),
        .data_out(data_out_16to64_2)
    );

    scrambler_top scrambler_top_1(
        .nreset(nreset),
        .valid(valid),
        .clk(clk),
        .data_in(data_in_input_sampler_16bit),
        .valid_out(valid_out_64bit),
        .data_out(data_out_64bit)
    );

    //wire for bit16to64_2
    reg [15:0] data_in_bit16to64_2;
    wire valid_out_bit16to64_2;
    wire [63:0] data_out_16to64_2;

    //wires for 64bit_scrambler_2
    wire [63:0] data_out_scrambler_64bit;
    wire valid_out_64bit_2;
    wire [15:0] data_out_16bit_2;
    wire valid_out_16bit_2;
    
    //for validation purpose
    reg [999:0] valid_array;
    //reg percentage_rate;
    function automatic bit creat_random_bit (int percentage_rate);
        if ($urandom_range(100,0)<=percentage_rate) begin
            return 1'b1;
        end
        else begin
            return 1'b0;
        end
    endfunction

    always #(CLK_PERIOD/2) clk=~clk;
    

`ifdef TEST_SCRAMBLER_16BIT

    initial begin: test_scrambler_16bit
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);
        //for the scrambler
        clk=0;
        pass_count = 0;
        fail_count = 0;
        //valid_in_bit16to64=1'b0;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;

        //Now for the 16bit scrambler
        nreset=0;
        #20;
        nreset=1'b1;

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
            //sampling the input into the inputSampler and from there to the scrambler_16bit_1
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
            if(xor_logic_output_scrambler_16bit_1!= golden_lfsr_bits_16bit[i])
            $display("Cycle %4d: LFSR MISMATCH (sequential=%04X, parallel=%04X)",i, golden_lfsr_bits_16bit[i], xor_logic_output_scrambler_16bit_1);
        end
        #20;
        $display("\n%0d PASSED, %0d FAILED", pass_count,fail_count);
        $finish;        
    end
`endif


`ifdef MAKING_WAVEFORM_GENERAL_CASE
    initial begin: making_waveform_general_case
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);    
        clk=0;
        valid=0;
        nreset=0;
        #20;
        nreset=1'b1;     

        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);
        for(i=0;i<1000;i=i+1) begin         
        inputs_16bit[i]=$random(seed) & 16'hFFFF; 
        end       
        //for the scrambler
        $display("hello1");
        i=0;
        @(posedge clk_out_for_clockDivider);
        data_in_input_sampler_16bit=inputs_16bit[i];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider); 
        valid=1'b0;
        #5;
        @(posedge clk_out_for_clockDivider);         
        data_in_input_sampler_16bit=inputs_16bit[i+1];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider);  
        valid=1'b0;      
        #5;        
        @(posedge clk_out_for_clockDivider); 
        data_in_input_sampler_16bit=inputs_16bit[i+2];
        valid=1'b1;       
        #5;
        @(posedge clk_out_for_clockDivider); 
        valid=1'b0;               
        @(posedge clk_out_for_clockDivider);  
        data_in_input_sampler_16bit=inputs_16bit[i+3];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider);
        valid=1'b0;       
        @(posedge clk_out_for_clockDivider);        
        data_in_input_sampler_16bit=inputs_16bit[i+4];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider);
        valid=1'b0;        
        @(posedge clk_out_for_clockDivider);        
        $finish;
    end
`endif


`ifdef MAKING_WAVEFORM_CONTINUES

        i=0;
        @(posedge clk_out_for_clockDivider);
        data_in_input_sampler_16bit=inputs_16bit[i];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider);        
        valid=1'b0;
        #5;
        data_in_input_sampler_16bit=inputs_16bit[i+1];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider);  
        #5;
        valid=1'b0;
        #5;
        data_in_input_sampler_16bit=inputs_16bit[i+2];
        valid=1'b1;                         
        #5;
        valid=1'b0;        
        @(posedge clk_out_for_clockDivider);  
        data_in_input_sampler_16bit=inputs_16bit[i+3];
        valid=1'b1;
        @(posedge clk_out_for_clockDivider);
        data_in_input_sampler_16bit=inputs_16bit[i+3];
        @(posedge clk_out_for_clockDivider);
        valid=1'b0;
`endif


`ifdef MAKING_WAVEFORM_DISCRETE

    i=0;
    @(posedge clk_out_for_clockDivider);
    data_in_input_sampler_16bit=inputs_16bit[i];
    valid=1'b1;
    @(posedge clk_out_for_clockDivider);        
    valid=1'b0;
    #5;
    @(posedge clk_out_for_clockDivider); 
    data_in_input_sampler_16bit=inputs_16bit[i+1];
    valid=1'b1;
    @(posedge clk_out_for_clockDivider);  
    #5;
    valid=1'b0;
    #5;
    @(posedge clk_out_for_clockDivider); 
    data_in_input_sampler_16bit=inputs_16bit[i+2];
    valid=1'b1;                         
    #5;
    @(posedge clk_out_for_clockDivider); 
    valid=1'b0;        
    @(posedge clk_out_for_clockDivider);  
    data_in_input_sampler_16bit=inputs_16bit[i+3];
    valid=1'b1;
    @(posedge clk_out_for_clockDivider);
    valid=1'b0;        
    @(posedge clk_out_for_clockDivider);        
    data_in_input_sampler_16bit=inputs_16bit[i+4];
    valid=1'b1;
    @(posedge clk_out_for_clockDivider);
    valid=1'b0;
`endif


`ifdef TEST_BIT16TO64

    initial begin: test_bit16to64bit
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);    
        clk=0;
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;        
        counter_16to64=2'b11;
        nreset=1'b0;
        #20;
        nreset=1'b1;
        //valid_in_bit16to64=1'b1;
        //The implimantation of the golden
        valid=1'b1;
        j=0;
        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);
        for(i=0;i<1000;i=i+1) begin 
            inputs_16bit[i]=$random(seed) & 16'hFFFF;
            expected_output_16bit[i]=inputs_16bit[i];            
        end    
        for (i=0;i<1000;i=i+1) begin
            valid=1'b1;
            if (valid) begin
                counter_16to64=counter_16to64+2'b01;
                case(counter_16to64)
                2'b00: expected_output_bit16to64[j][15:0]=expected_output_16bit[i];
                2'b01: expected_output_bit16to64[j][31:16]=expected_output_16bit[i];
                2'b10: expected_output_bit16to64[j][47:32]=expected_output_16bit[i];
                2'b11: begin
                    expected_output_bit16to64[j][63:48]=expected_output_16bit[i];
                    j=j+1;
                end
                default: expected_output_bit16to64[j]=64'b0;
                endcase
            end
        end
        //now creating the driver
        j=0;
        valid=1'b0;
        for(i=0;i<1000;i=i+1) begin
            data_in_bit16to64_2=expected_output_16bit[i];
            valid=1'b1;
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_bit16to64_2) begin
                if(data_out_16to64_2==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_16to64_2);  
                    j=j+1;                    
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[i],data_out_16to64_2);
                    fail_count_bit16to64=fail_count_bit16to64+1;
                end
            end
        end
            $display("\nbit16to64:\n%0d PASSED, %0d FAILED", pass_count_bit16to64,fail_count_bit16to64);
        #20
        $finish;    
    end
`endif


`ifdef TEST_SCRAMBLER_64BIT
    initial begin: test_scrambler_64bit
    //for 64bit
        clk=0;
        pass_count = 0;
        fail_count = 0;
        //valid_in_bit16to64=1'b0;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;        
        nreset=0;
        #20;
        nreset=1'b1;
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
            //sampling the input into the inputSampler and from there to the scrambler_64bit_1            
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
            if(xor_logic_output_scrambler_64bit_1!= golden_lfsr_bits_64bit[i])
            $display("Cycle %4d: LFSR MISMATCH (sequential=%04X, parallel=%04X)",i, golden_lfsr_bits_64bit[i], xor_logic_output_scrambler_64bit_1);
        end
        #20;
        $display("\n%0d PASSED, %0d FAILED", pass_count,fail_count);
        $finish;  
    end
`endif

`ifdef TEST_SEED_IS_ZERO_16BIT
    initial begin: test_seed_is_zero_16bit
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);        
        clk=0;
        pass_count = 0;
        fail_count = 0;
        //valid_in_bit16to64=1'b0;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;        
        nreset=0;
        #20;
        nreset=1'b1;
        inputs_64bit[0]=64'h1111222233334444;
        i=0;        
        @(posedge clk_out_for_clockDivider); 
        data_in_input_sampler_64bit=inputs_64bit[i];   
        valid=1'b1;        
        @(posedge clk_out_for_clockDivider); 
        @(posedge clk_out_for_clockDivider); 
        @(posedge clk_out_for_clockDivider); 
        @(posedge clk_out_for_clockDivider);                                                                 
        $finish;

  end
`endif


`ifdef TEST_SEED_IS_FULL_ONE_16TO16SCRAMBLER
    initial begin: test_seed_is_full_one_16to16scrambler
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);        
        clk=0;
        pass_count = 0;
        fail_count = 0;
        //valid_in_bit16to64=1'b0;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;        
        nreset=0;
        #20;
        nreset=1'b1;
        inputs_16bit[0]=16'h1111;
        inputs_16bit[1]=16'h2222;
        inputs_16bit[2]=16'h3333;
        inputs_16bit[3]=16'h4444; 


        i=0;        
        @(posedge clk_out_for_clockDivider); 
        data_in_input_sampler_16bit=inputs_16bit[0];   
        valid=1'b1;        
        @(posedge clk_out_for_clockDivider);
        valid=1'b0;                 
        @(posedge clk_out_for_clockDivider);
        data_in_input_sampler_16bit=inputs_16bit[1];   
        valid=1'b1;         
        @(posedge clk_out_for_clockDivider); 
        valid=1'b0;        
        @(posedge clk_out_for_clockDivider); 
        @(posedge clk_out_for_clockDivider);                                                     
        $finish;

  end
`endif


`ifdef TEST_SEED_IS_FULL_ONE_64TO64SCRAMBLER
    initial begin: test_seed_is_full_one_64to64scrambler
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);        
        clk=0;
        //pass_count = 0;
        //fail_count = 0;
        //valid_in_bit16to64=1'b0;
        valid=0;
        //for bit16to64
        //pass_count_bit16to64=0;
        //fail_count_bit16to64=0;        
        nreset=0;
        #20;
        nreset=1'b1;
        inputs_64bit[0]=64'h0000111122223333;
        inputs_64bit[1]=64'h1111222233334444;


        i=0;        
        @(posedge clk_out_for_clockDivider); 
        data_in_input_sampler_64bit=inputs_64bit[0];   
        valid=1'b1;        
        @(posedge clk_out_for_clockDivider);
        valid=1'b0;                 
        @(posedge clk_out_for_clockDivider);
        data_in_input_sampler_64bit=inputs_64bit[1];   
        valid=1'b1;         
        @(posedge clk_out_for_clockDivider); 
        valid=1'b0;        
        @(posedge clk_out_for_clockDivider); 
        @(posedge clk_out_for_clockDivider);                                                     
        $finish;

  end
`endif

`ifdef TEST_FULL_TOP_END2END
   initial begin: test_full_top_end2end
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);        
        clk=0;
        pass_count = 0;
        fail_count = 0;
        counter_16to64=2'b11;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;

        //Now for the 16bit scrambler
        nreset=0;
        #20;
        nreset=1'b1;
        j=0; 
        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);
        //generating my inputs
        for(i=0;i<1000;i=i+1) begin 
            inputs_16bit[i]=$random(seed) & 16'hFFFF;
            expected_output_16bit[i]=inputs_16bit[i];            
        end    
        for (i=0;i<1000;i=i+1) begin
            valid=1'b1;
            if (valid) begin
                counter_16to64=counter_16to64+2'b01;
                case(counter_16to64)
                2'b00: expected_output_bit16to64[j][15:0]=expected_output_16bit[i];
                2'b01: expected_output_bit16to64[j][31:16]=expected_output_16bit[i];
                2'b10: expected_output_bit16to64[j][47:32]=expected_output_16bit[i];
                2'b11: begin
                    expected_output_bit16to64[j][63:48]=expected_output_16bit[i];
                    j=j+1;
                end
                default: expected_output_bit16to64[j]=64'b0;
                endcase
            end
        end
        //creating driver
        j=0;
        valid=1'b0;
        for(i=0;i<1000;i=i+1) begin
            //sampling the input into the inputSampler and from there to the scrambler_16bit_1
            data_in_input_sampler_16bit=inputs_16bit[i];
            valid=1'b1;
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_64bit) begin      
                if(data_out_64bit==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);  
                    j=j+1;
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);
                    fail_count_bit16to64=fail_count_bit16to64+1;
                end
            end 
        end
        //cleaning the pipe
        valid=1'b0;
        for(i=0;i<4*CLK_PERIOD;i=i+1) begin
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_64bit) begin   
                if(data_out_64bit==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);  
                    j=j+1;
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);
                    fail_count_bit16to64=fail_count_bit16to64+1;
                end
            end                
        $display("\nFull End To End:\n%0d PASSED, %0d FAILED", pass_count_bit16to64,fail_count_bit16to64);
        #20;
        $finish;           
        end 
   end
`endif

`ifdef TEST_INCONTINOUS_VALID
   initial begin: test_incontinous_valid
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);        
        clk=0;
        pass_count = 0;
        fail_count = 0;
        counter_16to64=2'b11;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;

        //Now for the 16bit scrambler
        nreset=0;
        #20;
        nreset=1'b1;
        j=0; 
        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);
        //generating my inputs
        for(i=0;i<1000;i=i+1) begin 
            valid_array[i]=creat_random_bit(50);
            inputs_16bit[i]=$random(seed) & 16'hFFFF;
            expected_output_16bit[i]=inputs_16bit[i];            
        end    
        for (i=0;i<1000;i=i+1) begin
            valid=valid_array[i];
            
            if (valid) begin
                $display("valid_array_bit:%b  valid=%b,\ni=%0d",valid_array[i],valid,i);                
                counter_16to64=counter_16to64+2'b01;
                case(counter_16to64)
                2'b00: expected_output_bit16to64[j][15:0]=expected_output_16bit[i];
                2'b01: expected_output_bit16to64[j][31:16]=expected_output_16bit[i];
                2'b10: expected_output_bit16to64[j][47:32]=expected_output_16bit[i];
                2'b11: begin
                    expected_output_bit16to64[j][63:48]=expected_output_16bit[i];
                    j=j+1;
                end
                default: expected_output_bit16to64[j]=64'b0;
                endcase
            end


        end
        //creating driver
        j=0;
        valid=1'b0;
        for(i=0;i<1000;i=i+1) begin
            //sampling the input into the inputSampler and from there to the scrambler_16bit_1
            data_in_input_sampler_16bit=inputs_16bit[i];
            valid=valid_array[i];
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_64bit) begin      
                if(data_out_64bit==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);  
                    j=j+1;
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);
                    fail_count_bit16to64=fail_count_bit16to64+1;               
                end
            end 
        end





        //cleaning the pipe
        valid=1'b0;
        for(i=0;i<4*CLK_PERIOD;i=i+1) begin
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_64bit) begin   
                if(data_out_64bit==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);  
                    j=j+1;
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);
                    fail_count_bit16to64=fail_count_bit16to64+1;
                end
            end                
        $display("\nFull End To End:\n%0d PASSED, %0d FAILED", pass_count_bit16to64,fail_count_bit16to64);
        #20;
        $finish;           
        end 
   end
`endif


`ifdef CHECK_SCRAMBLER_TOP
   initial begin: check_scrambler_top
        $dumpfile("scrambler_tb.vcd");
        $dumpvars(0, scrambler_tb);        
        clk=0;
        pass_count = 0;
        fail_count = 0;
        counter_16to64=2'b11;
        valid=0;
        //for bit16to64
        pass_count_bit16to64=0;
        fail_count_bit16to64=0;

        //Now for the 16bit scrambler
        nreset=0;
        #20;
        nreset=1'b1;
        j=0; 
        if(!$value$plusargs("seed=%d", seed)) seed=1;
        seed=$random(seed);
        //generating my inputs
        for(i=0;i<1000;i=i+1) begin 
            valid_array[i]=creat_random_bit(50);
            inputs_16bit[i]=$random(seed) & 16'hFFFF;
            expected_output_16bit[i]=inputs_16bit[i];            
        end    
        for (i=0;i<1000;i=i+1) begin
            valid=valid_array[i];
            
            if (valid) begin
                $display("valid_array_bit:%b  valid=%b,\ni=%0d",valid_array[i],valid,i);                
                counter_16to64=counter_16to64+2'b01;
                case(counter_16to64)
                2'b00: expected_output_bit16to64[j][15:0]=expected_output_16bit[i];
                2'b01: expected_output_bit16to64[j][31:16]=expected_output_16bit[i];
                2'b10: expected_output_bit16to64[j][47:32]=expected_output_16bit[i];
                2'b11: begin
                    expected_output_bit16to64[j][63:48]=expected_output_16bit[i];
                    j=j+1;
                end
                default: expected_output_bit16to64[j]=64'b0;
                endcase
            end


        end
        //creating driver
        j=0;
        valid=1'b0;
        for(i=0;i<1000;i=i+1) begin
            //sampling the input into the inputSampler and from there to the scrambler_16bit_1
            data_in_input_sampler_16bit=inputs_16bit[i];
            valid=valid_array[i];
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_64bit) begin      
                if(data_out_64bit==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);  
                    j=j+1;
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);
                    fail_count_bit16to64=fail_count_bit16to64+1;               
                end
            end 
        end





        //cleaning the pipe
        valid=1'b0;
        for(i=0;i<4*CLK_PERIOD;i=i+1) begin
            @(posedge clk_out_for_clockDivider);
            #2;
            if(valid_out_64bit) begin   
                if(data_out_64bit==expected_output_bit16to64[j]) begin
                    pass_count_bit16to64=pass_count_bit16to64+1;
                    $display("Cycle %4d:Succeed (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);  
                    j=j+1;
                end
                else begin
                    $display("Cycle %4d:FAIL (expected=%04X, actual=%04X)",i,expected_output_bit16to64[j],data_out_64bit);
                    fail_count_bit16to64=fail_count_bit16to64+1;
                end
            end                
        $display("\nFull End To End:\n%0d PASSED, %0d FAILED", pass_count_bit16to64,fail_count_bit16to64);
        #20;
        $finish;           
        end 
   end
`endif


endmodule