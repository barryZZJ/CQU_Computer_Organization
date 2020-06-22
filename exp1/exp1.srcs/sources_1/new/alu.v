module alu(input [7:0] a,
           input [7:0] b,
           input [2:0] op,
           output[7:0] res);

assign res = (op == 3'b000) ? a + b:
             (op == 3'b001) ? a - b:
             (op == 3'b010) ? a & b:
             (op == 3'b011) ? a | b:
             (op == 3'b100) ? ~a:
             (op == 3'b101) ? ((a<b) ? 8'b00000001 : 8'b0) :
             8'b0; // 未使用端口默认输出0

endmodule
