`timescale 1ps / 1ps

module sim2_debug;

    reg clk;
    reg rst;

    //Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg cin;
    reg valid_in;
    reg allow_out;
    reg [3:0] stall;
    reg [3:0] clear;

    //Outputs
    wire valid_out;
    wire [31:0] sum;
    wire cout;
    wire pipe0_valid;
    wire pipe1_valid;
    wire pipe2_valid;
    wire pipe3_valid;
    wire [7:0] pipe0_sum;
    wire [15:0] pipe1_sum;
    wire [23:0] pipe2_sum;
    wire cout_t0;
    wire cout_t1;
    wire cout_t2;
    wire pipe0_allow_in;
    wire pipe1_allow_in;
    wire pipe2_allow_in;
    wire pipe3_allow_in;
    wire pipe0_ready_out;
    wire pipe1_ready_out;
    wire pipe2_ready_out;
    wire pipe3_ready_out;
    wire pipe0_to_next_valid;
    wire pipe1_to_next_valid;
    wire pipe2_to_next_valid;

    initial begin
        clk = 0;
        rst = 1'b1;
        a = 32'b00000011_11111100_11111111_00000000;
        b = 32'b00000001_00000100_00000001_00000011;
        cin = 1'b0;
        valid_in = 1'b1;
        allow_out = 1'b1;
        stall = 4'b0000;
        clear = 4'b0000;
    end
    
    stallable_pipeline_adder_debug utt (
        clk,
        a,
        b,
        cin,
        valid_in,
        allow_out,
        stall,
        clear,
        rst,
        valid_out,
        sum,
        cout,
        pipe0_valid,
        pipe1_valid,
        pipe2_valid,
        pipe3_valid,
        pipe0_sum,
        pipe1_sum,
        pipe2_sum,
        cout_t0,
        cout_t1,
        cout_t2,
        pipe0_allow_in,
        pipe1_allow_in,
        pipe2_allow_in,
        pipe3_allow_in,
        pipe0_ready_out,
        pipe1_ready_out,
        pipe2_ready_out,
        pipe3_ready_out,
        pipe0_to_next_valid,
        pipe1_to_next_valid,
        pipe2_to_next_valid
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) 
        clk=~clk;

    initial begin
        // 延迟一周期用于重置
        #CLK_PERIOD
        // 开始计算
        rst = 1'b0;
        # (2*CLK_PERIOD)
        a = 1;
        b = 1;
        # (2*CLK_PERIOD)
        a = 2;
        b = 2;
        # (2*CLK_PERIOD)
        a = 3;
        b = 3;
        # (2*CLK_PERIOD)
        a = 4;
        b = 4;
        # (10*CLK_PERIOD)
        // 10周期后暂停流水线第二级两周期
        stall[1] = 1'b1;
        # (2*CLK_PERIOD)
        stall[1] = 1'b0;
        // 15周期时刷新第三级流水线
        # (10*CLK_PERIOD)
        clear[2] = 1'b1;
        # CLK_PERIOD
        clear[2] = 1'b0;
        # CLK_PERIOD

        $finish;
    end

endmodule