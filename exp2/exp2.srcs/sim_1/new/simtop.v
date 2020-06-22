`timescale 1ns / 1ps

module simtop;

reg clk, rst;
wire jump, branch, alusrc, memwrite, memtoreg, regwirte, regdst;
wire [2:0] alucontrol;
wire [31:0] inst;

top top (
    .clk(clk),
    .rst(rst),
    .jump(jump),
    .branch(branch),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .memtoreg(memtoreg),
    .regwirte(regwirte),
    .regdst(regdst),
    .alucontrol(alucontrol),
    .inst(inst)
);

always #5 clk=~clk;
initial 
begin
    clk=0; rst=0;
    #1 rst=1;
    #1 rst=0;
    #24 $display("instruction:32'h %h, jump:%b,branch:%b,alusrc:%b,memwrite:%b,memtoreg:%b,regwirte:%b,regdst:%b,alucontrol:3'b%b",
                    inst,jump,branch,alusrc,memwrite,memtoreg,regwirte,regdst,alucontrol);
    #10 $display("instruction:32'h %h, jump:%b,branch:%b,alusrc:%b,memwrite:%b,memtoreg:%b,regwirte:%b,regdst:%b,alucontrol:3'b%b",
                    inst,jump,branch,alusrc,memwrite,memtoreg,regwirte,regdst,alucontrol);
    #10 $display("instruction:32'h %h, jump:%b,branch:%b,alusrc:%b,memwrite:%b,memtoreg:%b,regwirte:%b,regdst:%b,alucontrol:3'b%b",
                    inst,jump,branch,alusrc,memwrite,memtoreg,regwirte,regdst,alucontrol);
    #10  $display("instruction:32'h %h, jump:%b,branch:%b,alusrc:%b,memwrite:%b,memtoreg:%b,regwirte:%b,regdst:%b,alucontrol:3'b%b",
                    inst,jump,branch,alusrc,memwrite,memtoreg,regwirte,regdst,alucontrol);
    #10  $display("instruction:32'h %h, jump:%b,branch:%b,alusrc:%b,memwrite:%b,memtoreg:%b,regwirte:%b,regdst:%b,alucontrol:3'b%b",
                    inst,jump,branch,alusrc,memwrite,memtoreg,regwirte,regdst,alucontrol);
    #10  $display("instruction:32'h %h, jump:%b,branch:%b,alusrc:%b,memwrite:%b,memtoreg:%b,regwirte:%b,regdst:%b,alucontrol:3'b%b",
                    inst,jump,branch,alusrc,memwrite,memtoreg,regwirte,regdst,alucontrol);
    #9 $stop;
end

endmodule
