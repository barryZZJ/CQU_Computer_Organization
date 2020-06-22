`timescale 1ns / 1ns

module sim;

    reg clk;

    //Inputs
    reg [7:0] num2;
    reg [7:0] num1;
    reg [2:0] op;

    //Outputs
    wire [7:0] res;

    initial begin
        clk = 0;
    end
    
    alu utt 
    (
        .a(num2),
        .b(num1),
        .op(op),
        .res(res)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) 
        clk=~clk;

    initial begin
        // +
        op = 3'b000;
        num2 = 8'b00000001;
        num1 = 8'b00000010;
        # CLK_PERIOD
        // -
        op = 3'b001;
        num1 = 8'b11111111;
        # CLK_PERIOD
        // AND
        op = 3'b010;
        num1 = 8'b11111110;
        # CLK_PERIOD
        // OR
        op = 3'b011;
        num1 = 8'b10101010;
        # CLK_PERIOD
        // ~A
        op = 3'b100;
        num1 = 8'b11110000;
        # CLK_PERIOD
        // SLT
        op = 3'b101;
        num1 = 8'b10000001;
        # CLK_PERIOD
        $finish;
    end

endmodule