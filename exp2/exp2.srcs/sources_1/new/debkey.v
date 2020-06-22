//按键消抖模块
//每隔50ms检查一次按下情况，如果两次按键情况一致则输出对应结果，不一致则输出0。
module debkey #(parameter T50MS = 50*10**5)
			   (input clk,
                input key,
                output debkey);
	//---------------------------------------------------------------	
	//50ms~
	reg key_r = 1'b0;
	reg key_rr = 1'b0;
	
	integer cnt_50ms = 0;
	reg clk_50ms;
	
	always @(posedge clk) begin
		if(cnt_50ms == T50MS) begin
			cnt_50ms <= 0;
			key_r <= key;
			key_rr <= key_r;
		end else begin
			cnt_50ms <= cnt_50ms + 1;
		end

	end

	assign debkey = key_r & key_rr;
	
endmodule