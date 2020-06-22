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
    
//�ֱ�Ϊ��pc+4, ��·ѡ���֧֮���pc, ��һ������Ҫִ�е�ָ���pc, �Ĵ��������1, �Ĵ��������2, ������������չ��Ľ��
wire [31:0] pc_4, pc_branched, pc_realnext, rd1, rd2, extend_imm;

//ALU���������Ĵ�����д�����ݣ�����2λ�������������ת��ַ
wire [31:0] ALUsrcB, wd3, sl2_imm, pc_Branch, sl2_inst, pc_jump;

//д��Ĵ����ѵĵ�ַ
wire [4:0] reg_WriteNumber;
   
assign mem_WriteData = rd2;
assign pc_jump = {pc[31:28], sl2_inst[27:0]};
       
//PC+4�ӷ���
adder pc_4_adder (
    .a(pc),
    .b(32'h4),
    .y(pc_4)
);
    
//mux, PCָ��ѡ��, PC+4(0), pc_src(1)
mux2 #(32) mux_pcbranch(
	.a(pc_Branch),//�������ݴ洢��
	.b(pc_4),//����ALU������
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
    
//������������2λ
sl2 sl2_1(
    .a(extend_imm),
    .y(sl2_imm)
);
      
//jumpָ�������2λ
sl2 sl2_2(
    .a({6'b0, inst[25:0]}),
    .y(sl2_inst)
);
      
//mux, ѡ���֧֮���pc��pc_jump
mux2 #(32) mux_pcnext(
	.a(pc_jump),//�������ݴ洢��
	.b(pc_branched),//����ALU������
	.s(jump),
	.y(pc_realnext)
);
    
//branch��ת��ַ�ӷ���
adder pc_branch_adder (
	.a(pc_4),
	.b(sl2_imm),
	.y(pc_Branch)
);
    

//������չ
signext sign_extend(
    .a(inst[15:0]),
    .y(extend_imm)
);
    
//mux,�Ĵ�����д���������Դ洢�� or ALU ��memtoReg
mux2 #(32) mux_WD3(
	.a(reg_WriteData),//�������ݴ洢��
	.b(aluout),//����ALU������
	.s(memtoreg),
	.y(wd3)
);
    
//mux,�Ĵ�����д���ַrt or rd��RegDst
mux2 #(5) mux_WA3(
	.a(inst[15:11]),//rt
	.b(inst[20:16]),//rd
	.s(regdst),
	.y(reg_WriteNumber)
);
    
//�Ĵ�����
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
    
//mux,ALU B������ֵ��rd2(0),imm(1)��alusrc
mux2 #(32) mux_ALUsrc(
    .a(extend_imm),//������
    .b(rd2),//�Ĵ�����
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
