// 有阻塞 4 级流水线 32bit 全加器
module stallable_pipeline_adder 
(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input cin,
    input valid_in,    // 输入是否有效
    input allow_out,   // 是否允许输出
    input [3:0] stall, // 各级暂停信号
    input [3:0] clear, // 各级流水线刷新信号
    input rst,
    output valid_out, // 输出是否有效
    output reg [31:0] sum, // 第31~24位计算求和，拼接低24位结果
    output reg cout
);

reg pipe_valid[0:3]; // 该级流水线有效数据（输入有效 且 后面的流水线都没有暂停）
reg [7:0] pipe0_sum; // 低 8 位求和
reg [15:0] pipe1_sum; // 第15~8位计算求和，拼接低8位结果
reg [23:0] pipe2_sum; // 第23~16位计算求和，拼接低16位结果
reg cout_t [0:2];

reg [31:0]tmp_a[0:2];
reg [31:0]tmp_b[0:2];

wire pipe_allow_in[0:3];      // 该级流水线允许输入（存的数据无效 或 准备好输出了且下一级允许输入）
reg pipe_ready_out[0:3];      // 该级准备好输出了（该级的数据处理完了）
wire pipe_to_next_valid[0:2]; // 可以向下一级传送有效数据（该级数据有效 且 准备好输出了）

// pipe 0

assign pipe_allow_in[0] = !pipe_valid[0] | pipe_ready_out[0] & pipe_allow_in[1];
assign pipe_to_next_valid[0] = pipe_valid[0] & pipe_ready_out[0];

always @(posedge clk) begin
    if (rst) begin
        pipe_valid[0] <= 1'b0;
    end else if (pipe_allow_in[0]) begin
        pipe_valid[0] <= (!stall[0] & !stall[1] & !stall[2] & !stall[3]) && valid_in;
    end

    if (valid_in && pipe_allow_in[0]) begin
        if (clear[0]) begin
            pipe0_sum <= 8'b0;
            cout_t[0] <= 1'b0;
            tmp_a[0] <= 0;
            tmp_b[0] <= 0;
        end else begin 
            {cout_t[0], pipe0_sum} <= a[7:0] + b[7:0] + cin;
            tmp_a[0] <= a;
            tmp_b[0] <= b;
        end
        pipe_ready_out[0] <= 1'b1;
    end else begin
        pipe_ready_out[0] <= 1'b0;
    end
end

// pipe 1

assign pipe_allow_in[1] = (!pipe_valid[1] || pipe_ready_out[1] && pipe_allow_in[2]);
assign pipe_to_next_valid[1] = pipe_valid[1] && pipe_ready_out[1];

always @(posedge clk) begin
    if (rst) begin
        pipe_valid[1] <= 1'b0;
    end else if (pipe_allow_in[1]) begin
        pipe_valid[1] <= (!stall[1] & !stall[2] & !stall[3]) && pipe_to_next_valid[0];
    end

    if (pipe_to_next_valid[0] && pipe_allow_in[1]) begin
        if (clear[1]) begin
            pipe1_sum <= 16'b0;
            cout_t[1] <= 1'b0;
            tmp_a[1] <= 0;
            tmp_b[1] <= 0;
        end else begin
            {cout_t[1], pipe1_sum} <= {{1'b0, tmp_a[0][15:8]} + {1'b0, tmp_b[0][15:8]} + cout_t[0], pipe0_sum};
            tmp_a[1] <= tmp_a[0];
            tmp_b[1] <= tmp_b[0];
        end
        pipe_ready_out[1] <= 1'b1;
    end else begin
        pipe_ready_out[1] <= 1'b0;
    end
end

// pipe 2

assign pipe_allow_in[2] = (!pipe_valid[2] || pipe_ready_out[2] && pipe_allow_in[3]);
assign pipe_to_next_valid[2] = pipe_valid[2] && pipe_ready_out[2];

always @(posedge clk) begin
    if (rst) begin
        pipe_valid[2] <= 1'b0;
    end else if (pipe_allow_in[2]) begin
        pipe_valid[2] <= (!stall[2] & !stall[3]) && pipe_to_next_valid[1];
    end

    if (pipe_to_next_valid[1] && pipe_allow_in[2]) begin
        if (clear[2]) begin
            pipe2_sum <= 24'b0;
            cout_t[2] <= 1'b0;
            tmp_a[2] <= 0;
            tmp_b[2] <= 0;
        end else begin
            {cout_t[2], pipe2_sum} <= {{1'b0, tmp_a[1][23:16]} + {1'b0, tmp_b[1][23:16]} + cout_t[1], pipe1_sum};
            tmp_a[2] <= tmp_a[1];
            tmp_b[2] <= tmp_b[1];
        end 
        pipe_ready_out[2] <= 1'b1;
    end else begin
        pipe_ready_out[2] <= 1'b0;
    end
end

// pipe 3

assign pipe_allow_in[3] = (!pipe_valid[3] || pipe_ready_out[3] && allow_out);

always @(posedge clk) begin
    if (rst) begin
        pipe_valid[3] <= 1'b0;
    end else if (pipe_allow_in[3]) begin
        pipe_valid[3] <= !stall[3] && pipe_to_next_valid[2];
    end

    if (pipe_to_next_valid[2] && pipe_allow_in[3]) begin
        if (clear[3]) begin
            sum <= 32'b0;
            cout <= 1'b0;
        end else begin
            {cout, sum} <= {{1'b0, tmp_a[2][31:24]} + {1'b0, tmp_b[2][31:24]} + cout_t[2], pipe2_sum};
        end
        pipe_ready_out[3] <= 1'b1;
    end else begin
        pipe_ready_out[3] <= 1'b0;
    end
end

assign valid_out = pipe_valid[3] && pipe_ready_out[3];

endmodule
