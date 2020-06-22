// ������ 4 ����ˮ�� 32bit ȫ����
module stallable_pipeline_adder 
(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input cin,
    input valid_in,    // �����Ƿ���Ч
    input allow_out,   // �Ƿ��������
    input [3:0] stall, // ������ͣ�ź�
    input [3:0] clear, // ������ˮ��ˢ���ź�
    input rst,
    output valid_out, // ����Ƿ���Ч
    output reg [31:0] sum, // ��31~24λ������ͣ�ƴ�ӵ�24λ���
    output reg cout
);

reg pipe_valid[0:3]; // �ü���ˮ����Ч���ݣ�������Ч �� �������ˮ�߶�û����ͣ��
reg [7:0] pipe0_sum; // �� 8 λ���
reg [15:0] pipe1_sum; // ��15~8λ������ͣ�ƴ�ӵ�8λ���
reg [23:0] pipe2_sum; // ��23~16λ������ͣ�ƴ�ӵ�16λ���
reg cout_t [0:2];

reg [31:0]tmp_a[0:2];
reg [31:0]tmp_b[0:2];

wire pipe_allow_in[0:3];      // �ü���ˮ���������루���������Ч �� ׼�������������һ���������룩
reg pipe_ready_out[0:3];      // �ü�׼��������ˣ��ü������ݴ������ˣ�
wire pipe_to_next_valid[0:2]; // ��������һ��������Ч���ݣ��ü�������Ч �� ׼��������ˣ�

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
