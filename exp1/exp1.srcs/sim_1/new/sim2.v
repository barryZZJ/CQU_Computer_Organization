`timescale 1ps / 1ps

module sim2;

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
    
    initial begin
        clk = 0;
        rst = 1'b1;
        a = 32'b0;
        b = 32'b1;
        cin = 1'b0;
        valid_in = 1'b1;
        allow_out = 1'b1;
        stall = 4'b0000;
        clear = 4'b0000;
    end
    
    stallable_pipeline_adder utt (
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
        cout
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) 
        clk=~clk;

    initial begin
        // �ӳ�һ������������
        #CLK_PERIOD
        // ��ʼ����
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

        # (3*CLK_PERIOD)
        // 10���ں���ͣ��ˮ�ߵڶ���������
        stall[1] = 1'b1;
        # (2*CLK_PERIOD)
        stall[1] = 1'b0;
        // 15����ʱˢ�µ�������ˮ��
        # (4*CLK_PERIOD)
        clear[2] = 1'b1;
        # (2*CLK_PERIOD)
        clear[2] = 1'b0;
        # (3*CLK_PERIOD)

        $finish;
    end

endmodule