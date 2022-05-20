// 最大池化模块
module maxpooling
(
    input  clk,
    input  rstn,
    input  ivalid,      // 输入有效
    input  state,       // 0: 24*24; 1: 8*8
    input  [7:0] din,   // 像素数据 8bit
    output ovalid,      // 输出有效
    output [7:0] dout   // 输出结果 
);

	reg [7:0] data [0:23];  // 缓存一行输入数据 24 or 8
	reg [6:0] ptr;          // 地址指针 0 ~ 47
	reg cnt;                // 由于只有 1 bit，所以超过会溢出， 0：data_reg_0，1：data_reg_1
	reg [7:0] data_reg_0;   // 缓存寄存器0
	reg [7:0] data_reg_1;   // 缓存寄存器1
	reg [7:0] dout_r;       // 最终输出结果
	
	// ptr 地址指针递增
	always@(posedge clk)begin
		if(!rstn)
			ptr <= 7'b0000000;
		else
			case(state)
				1'b0:begin
					if(ptr == 7'd48-1) // 2*24 两行，从0算起，所以需要减1
						ptr <= 7'd0;
					else 
						if(!ivalid)
							ptr <= ptr;
						else
							ptr <= ptr + 7'd1;
					end
				1'b1:begin
					if(ptr == 7'd16-1) // 2*8 两行
						ptr <= 7'd0;
					else 
						if(!ivalid)
							ptr <= ptr;
						else
							ptr <= ptr + 7'd1;
					end               
			endcase
	end
	
	// cnt 计数
	// 24 -> cnt=0 、25 -> cnt=1
	// 26 -> cnt=0 、27 -> cnt=1
	// ...
	always@(posedge clk or negedge rstn)begin
	if(!rstn)
		cnt <= 0;
	else
		case(state)
			1'b0:begin
					if(ptr < 7'd25 - 1) //慢一拍
						cnt <= 0;
					else
						if(ivalid)
							cnt <= cnt + 1'b1;
						else
							cnt <= cnt;
				end
			1'b1:begin
					if(ptr <= 7'd7)
						cnt <= 0;
					else
						if(ivalid)
							cnt <= cnt + 1'b1;
						else
							cnt <= cnt;
				end
		endcase
	end
	
	// 行数据缓存
	always@(posedge clk)
	begin
		case(state)
		1'b0:begin
			if(ptr <= 7'd24 && ivalid) 
				data[ptr] <= din;
			end
		1'b1:begin
			if(ptr <= 7'd8 && ivalid) 
				data[ptr] <= din;
			end          
		endcase   
	end
	// 两行对应索引数据对比，缓存较大值
	always@(posedge clk)
	begin
		case({state,cnt}) // 这里的 cnt是触发时的值，而不是计算后的值
		2'b00:begin
			if(ptr >= 7'd24)
			begin
				if(din>data[ptr-7'd24])
					data_reg_0 <= din;
				else
					data_reg_0 <= data[ptr-7'd24];
			end
			else
				data_reg_0 <= 0;
			end
		2'b01:begin
			if(ptr >= 7'd24)
			begin
				if(din>data[ptr-7'd24])
					data_reg_1 <= din;
				else
					data_reg_1 <= data[ptr-7'd24];
			end
			else
				data_reg_1 <= 0;
			end
		2'b10:begin
			if(ptr >= 7'd9)
			begin
				if(din>data[ptr-7'd9])
					data_reg_0 <= din;
				else
					data_reg_0 <= data[ptr-7'd9];
			end
			else
				data_reg_0 <= 0;
			end
		2'b11:begin
			if(ptr >= 7'd9)
			begin
				if(din>data[ptr-7'd9])
					data_reg_1 <= din;
				else
					data_reg_1 <= data[ptr-7'd9];
			end
			else
				data_reg_1 <= 0;
			end 
		default:begin
				data_reg_1 <= 0; 
				data_reg_0 <= 0;
				end         
		endcase
	end

	// 打拍采沿
	reg cnt_d;
	always@(posedge clk)begin
		if(!rstn)
			cnt_d <= 0;
		else
			cnt_d <= cnt;
	end
	
	// cnt 为 1时，输出才是有效的，即 2*2 的kernel， cnt=1含义为第二行且为偶数位索引（从1计数）
	// 筛选输出数据
	assign ovalid = ~cnt && cnt_d; // 采样下降沿
	assign dout   = data_reg_1 > data_reg_0 ? data_reg_1 : data_reg_0;
	
endmodule
