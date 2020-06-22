`timescale 1ns / 1ps

module controller(input [5:0] op,
                  input [5:0] funct,
                  output regdst,
                  output regwrite,
                  output alusrc,
                  output memwrite,
                  output memtoreg,
                  output branch,
                  output jump,
                  output [2:0]alucontrol);

wire [1:0]aluop;

main_decoder main_decoder(
    .op(op),
    .regdst(regdst),
    .regwrite(regwrite),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .memtoreg(memtoreg),
    .branch(branch),
    .jump(jump),
    .aluop(aluop)
);

aludec aludec(
    .funct(funct),
    .aluop(aluop),
    .alucontrol(alucontrol)
);

endmodule
