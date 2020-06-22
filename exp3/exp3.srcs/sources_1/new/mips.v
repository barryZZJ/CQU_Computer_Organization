`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips(
	input wire clk,rst,
	input wire[31:0] instr,
	input wire[31:0] readdata,

	output wire memwrite,
	output wire[31:0] pc, result,
	output wire[31:0] aluout, writedata,
	output [4:0] rs, rt, rd
);
	
wire memtoreg,alusrc,regdst,regwrite,jump,pcsrc,zero;
wire[2:0] alucontrol;

wire branch;

assign pcsrc = branch & zero;
assign rs = instr[25:21];
assign rt = instr[20:16];
assign rd = instr[15:11];

controller c(
	.op(instr[31:26]),
	.funct(instr[5:0]),
	.memtoreg(memtoreg),
	.memwrite(memwrite),
	.alusrc(alusrc),
	.regdst(regdst),
	.regwrite(regwrite),
	.branch(branch),
	.jump(jump),
	.alucontrol(alucontrol)
);

datapath dp(
	.clk(clk),
	.rst(rst),
	.inst(instr),
	.reg_WriteData(readdata),
	.memtoreg(memtoreg),
	.pcsrc(pcsrc),
	.alusrc(alusrc),
	.regdst(regdst),
	.regwrite(regwrite),
	.jump(jump),
	.alucontrol(alucontrol),
	.zero(zero),
	.pc(pc),
	.aluout(aluout),
	.mem_WriteData(writedata),
	.wd3(result)
);
	
endmodule
