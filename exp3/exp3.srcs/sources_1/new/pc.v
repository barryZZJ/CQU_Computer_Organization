`timescale 1ns / 1ps

module pc_module(input clk,
                 input rst,
                 input [31:0] d,
                 output reg [31:0] pc);
    
always @(posedge clk, posedge rst) begin
    if (rst) begin
        pc <= 0;
        end else begin
        pc <= d;
    end
end
    
endmodule
    
