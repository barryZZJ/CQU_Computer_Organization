`timescale 1ns / 1ps


module top(
	input wire clk,rst,
    output [31:0] instr, pc, result, // for testbench
	output [4:0] rs, rt, rd,
	output wire [31:0] writedata, dataadr,
	output wire memwrite
);

	wire [31:0] pc,instr;
	wire [31:0] readdata; 

	mips mips(
		.clk(clk),
		.rst(rst),
		.instr(instr),
		.readdata(readdata),
		.memwrite(memwrite),
		.pc(pc),
		.aluout(dataadr),
		.writedata(writedata),
		.rs(rs),
		.rt(rt),
		.rd(rd),
		.result(result)
	);
	
	inst_ram inst_ram(
		.clka(~clk),
        .ena(1'b1),      // input wire ena
        .wea(4'b0000),      // input wire [3 : 0] wea
		.addra({2'b0, pc[7:2]}),
        .dina(32'b0),    // input wire [31 : 0] dina
		.douta(instr)
	);
	
	data_ram data_ram(
		.clka(~clk),
		.ena(1'b1),
		.wea({4{memwrite}}),
		.addra(dataadr),
		.dina(writedata),	 // Ҫд��洢���е�����
		.douta(readdata)	 // �Ӵ洢���ж���������
	);

endmodule
