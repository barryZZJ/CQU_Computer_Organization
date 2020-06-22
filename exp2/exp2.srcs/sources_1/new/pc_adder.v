`timescale 1ns / 1ps

module pc_adder(input [7:0] a,
                input [7:0] b,
                output [7:0] c);

    assign c = a + b;

endmodule
