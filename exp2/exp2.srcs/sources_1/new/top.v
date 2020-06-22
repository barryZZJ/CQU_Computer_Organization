`timescale 1ns / 1ps

module top(input clk,
           input rst,
           output regdst,
           output regwirte,
           output alusrc,
           output memwrite,
           output memtoreg,
           output branch,
           output jump,
           output [2:0] alucontrol,
           output [31:0] inst);

// pc��ӷ���
// pc �����byte��32bit(4Byte)�ĵ�ַ��Ӧpc��4λ��ÿ�μ�4��byte
wire [7:0] pc;
wire [7:0] pc_next; // ��һ�����ڵ�pcֵ
wire inst_ce; // ��ָ��洢����ʹ�ܿ���

pc_adder pc_adder(
    pc,
    8'h4,
    pc_next
);

pc_module pc_module(
    .clk(clk),
    .rst(rst),
    .d(pc_next),
    .pc(pc),
    .inst_ce(inst_ce)
);


//ָ��洢��
mem mem (
    .clka(clk),
    .ena(inst_ce),
    .wea(0), // дʹ��
    .addra({2'b0, pc[7:2]}), // �����ַ����Ѱַ����Ӧpc/4
    .dina(0),
    .douta(inst)
);

//������
controller controller(
    .inst(inst),
    .regdst(regdst),
    .regwirte(regwirte),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .memtoreg(memtoreg),
    .branch(branch),
    .jump(jump),
    .alucontrol(alucontrol)
);
    
endmodule
