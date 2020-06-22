`timescale 1ns / 1ps

module pc_module(input clk,
                 input rst,
                 input [7:0] d,
                 output reg [7:0] pc,
                 output reg inst_ce);
    
always @(posedge clk, posedge rst) begin
    if (rst) begin
        pc      <= -4;
        inst_ce <= 1'b0;
    end else begin
        pc      <= d;
        inst_ce <= 1'b1;
    end
end

endmodule
    
