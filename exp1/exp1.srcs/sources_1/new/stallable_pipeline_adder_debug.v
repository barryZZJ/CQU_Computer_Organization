// 有阻塞 4 级流水线 32bit 全加器
module stallable_pipeline_adder_debug
(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input cin,
    input valid_in,
    input allow_out,
    input [3:0] stall, // 各级暂停信号
    input [3:0] clear, // 各级流水线刷新信号
    input rst,
    output valid_out, // 输出是否有效
    output reg [31:0] sum,
    output reg cout,
    output pipe0_valid,
    output pipe1_valid,
    output pipe2_valid,
    output pipe3_valid,
    output [7:0] pipe0_sum,
    output [15:0] pipe1_sum,
    output [23:0] pipe2_sum,
    output cout_t0,
    output cout_t1,
    output cout_t2,
    output pipe0_allow_in,
    output pipe1_allow_in,
    output pipe2_allow_in,
    output pipe3_allow_in,
    output pipe0_ready_out,
    output pipe1_ready_out,
    output pipe2_ready_out,
    output pipe3_ready_out,
    output pipe0_to_next_valid,
    output pipe1_to_next_valid,
    output pipe2_to_next_valid
);

assign pipe0_valid = pipe_valid[0];
assign pipe1_valid = pipe_valid[1];
assign pipe2_valid = pipe_valid[2];
assign pipe3_valid = pipe_valid[3];
assign cout_t0 = cout_t[0];
assign cout_t1 = cout_t[1];
assign cout_t2 = cout_t[2];
assign pipe0_allow_in = pipe_allow_in[0];
assign pipe1_allow_in = pipe_allow_in[1];
assign pipe2_allow_in = pipe_allow_in[2];
assign pipe3_allow_in = pipe_allow_in[3];
assign pipe0_ready_out = pipe_ready_out[0];
assign pipe1_ready_out = pipe_ready_out[1];
assign pipe2_ready_out = pipe_ready_out[2];
assign pipe3_ready_out = pipe_ready_out[3];
assign pipe0_to_next_valid = pipe_to_next_valid[0];
assign pipe1_to_next_valid = pipe_to_next_valid[1];
assign pipe2_to_next_valid = pipe_to_next_valid[2];


reg pipe_valid[0:3]; // 该级流水线存有有效数据
reg [7:0] pipe0_sum;
reg [15:0] pipe1_sum;
reg [23:0] pipe2_sum;
reg cout_t [0:2];

wire pipe_allow_in[0:3];
reg pipe_ready_out[0:3];
wire pipe_to_next_valid[0:2];

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
        end else begin 
            {cout_t[0], pipe0_sum} <= a[7:0] + b[7:0] + cin;
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
        end else begin
            {cout_t[1], pipe1_sum} <= {{1'b0, a[15:8]} + {1'b0, b[15:8]} + cout_t[0], pipe0_sum};
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
        end else begin
            {cout_t[2], pipe2_sum} <= {{1'b0, a[23:16]} + {1'b0, b[23:16]} + cout_t[1], pipe1_sum};
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
            {cout, sum} <= {{1'b0, a[31:24]} + {1'b0, b[31:24]} + cout_t[2], pipe2_sum};
        end
        pipe_ready_out[3] <= 1'b1;
    end else begin
        pipe_ready_out[3] <= 1'b0;
    end
end

assign valid_out = pipe_valid[3] && pipe_ready_out[3];

endmodule
