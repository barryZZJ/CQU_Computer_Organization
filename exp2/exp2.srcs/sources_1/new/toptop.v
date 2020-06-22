`timescale 1ns / 1ps

module top_for_board(input clk,
                     input rst,
                     input clk_btn,            // 按钮时钟信号
                     output regdst,
                     output regwirte,
                     output alusrc,
                     output memwrite,
                     output memtoreg,
                     output branch,
                     output jump,
                     output [2:0] alucontrol,
                     output wire [6:0] seg,    // 数码管显示指令
                     output wire [7:0] ans);
    
wire clk_out;
wire [31:0] inst;

//消抖
debkey debkey(
    .clk(clk),
    .key(clk_btn),
    .debkey(clk_out)
);

top top(
    .clk(clk_out),
    .rst(rst),
    .regdst(regdst),
    .regwirte(regwirte),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .memtoreg(memtoreg),
    .branch(branch),
    .jump(jump),
    .alucontrol(alucontrol),
    .inst(inst)
);

display display(
    .clk(clk),
    .reset(rst),
    .s(inst),
    .seg(seg),
    .ans(ans)
);

endmodule
