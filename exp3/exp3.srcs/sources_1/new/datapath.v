`timescale 1ns / 1ps

module datapath(
    input clk,rst,
    input [31:0]inst, reg_WriteData,
    input jump,
    input pcsrc,
    input alusrc,
    input memtoreg,
    input regwrite,
    input regdst,
    input [2:0] alucontrol,

    output zero,
    output [31:0] pc, aluout, mem_WriteData, wd3
);
    
//分别为：pc+4, 多路选择分支之后的pc, 下一条真正要执行的指令的pc, 寄存器堆输出1, 寄存器堆输出2, 立即数符号拓展后的结果
wire [31:0] pc_4, pc_branched, pc_realnext, rd1, rd2, extend_imm;

//ALU计算结果，寄存器堆写入数据，左移2位后的立即数，跳转地址
wire [31:0] ALUsrcB, wd3, sl2_imm, pc_Branch, sl2_inst, pc_jump;

//写入寄存器堆的地址
wire [4:0] reg_WriteNumber;
   
assign mem_WriteData = rd2;
assign pc_jump = {pc[31:28], sl2_inst[27:0]};
       
//PC+4加法器
adder pc_4_adder (
    .a(pc),
    .b(32'h4),
    .y(pc_4)
);
    
//mux, PC指向选择, PC+4(0), pc_src(1)
mux2 #(32) mux_pcbranch(
	.a(pc_Branch),//来自数据存储器
	.b(pc_4),//来自ALU计算结果
	.s(pcsrc),
	.y(pc_branched)
);
    
//pc
pc_module pc_module(
	.clk(clk),
	.rst(rst),
    .d(pc_realnext),
    .pc(pc)
);
    
//立即数的左移2位
sl2 sl2_1(
    .a(extend_imm),
    .y(sl2_imm)
);
      
//jump指令的左移2位
sl2 sl2_2(
    .a({6'b0, inst[25:0]}),
    .y(sl2_inst)
);
      
//mux, 选择分支之后的pc与pc_jump
mux2 #(32) mux_pcnext(
	.a(pc_jump),//来自数据存储器
	.b(pc_branched),//来自ALU计算结果
	.s(jump),
	.y(pc_realnext)
);
    
//branch跳转地址加法器
adder pc_branch_adder (
	.a(pc_4),
	.b(sl2_imm),
	.y(pc_Branch)
);
    

//符号拓展
signext sign_extend(
    .a(inst[15:0]),
    .y(extend_imm)
);
    
//mux,寄存器堆写入数据来自存储器 or ALU ，memtoReg
mux2 #(32) mux_WD3(
	.a(reg_WriteData),//来自数据存储器
	.b(aluout),//来自ALU计算结果
	.s(memtoreg),
	.y(wd3)
);
    
//mux,寄存器堆写入地址rt or rd，RegDst
mux2 #(5) mux_WA3(
	.a(inst[15:11]),//rt
	.b(inst[20:16]),//rd
	.s(regdst),
	.y(reg_WriteNumber)
);
    
//寄存器堆
regfile regfile(
	.clk(clk),
	.we3(regwrite),
	.ra1(inst[25:21]),
	.ra2(inst[20:16]),
	.wa3(reg_WriteNumber),
	.wd3(wd3),
	.rd1(rd1),
	.rd2(rd2)
);
    
//mux,ALU B端输入值，rd2(0),imm(1)，alusrc
mux2 #(32) mux_ALUsrc(
    .a(extend_imm),//立即数
    .b(rd2),//寄存器堆
    .s(alusrc),
    .y(ALUsrcB)
);
    
    
//ALU
alu alu(
    .a(rd1),
    .b(ALUsrcB),
    .op(alucontrol),

    .res(aluout),
    .zero(zero)
);

endmodule
