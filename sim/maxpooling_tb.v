`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:jccao
// 
// Create Date: 2022/05/01 09:28:10
// Design Name: 
// Module Name: maxpooling_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// 需要配置的的地方为 (1)
module maxpooling_tb();
	// 输入
	reg clk;
	reg rstn;
	reg ivalid;
	reg state;
	reg [7:0] din;
	
	// 输出
	wire[7:0] dout;
	wire ovalid;
	
	integer STATE = 0; // 输入图像 Size 配置 0: 24x24 1:8x8 
	reg[10:0] cnt_line; // 读取行数计数
	integer count_w,fp_i;// 文件指针
	
	reg [7:0] pool_result_tb [0:150]; //用于缓存池化计算结果 12x12=144
	reg [10:0] cnt_pool; // 缓存的卷积计算结果计数
	
	// maxpooling module
	maxpooling u_maxpooling(
	.clk(clk),
	.rstn(rstn),
	.ivalid(ivalid),
	.state(state),
	.din(din),
	.dout(dout),
	.ovalid(ovalid)
	);
	
	// 初始信号赋值-maxpooling module
	initial
	begin
		clk = 0;
		rstn = 0; // 复位
		cnt_line = 0; //行数清零
		cnt_pool = 0; //计数清零
		state = STATE;
		ivalid = 0; 
		din = 0;
		# 20; // 一周期后填充数据，即 ivalid = 1前数据就要准备好
		rstn = 1;
		ivalid = 1; // input valid
	end
	
	// 读取图片数据
	initial
	begin
		fp_i = $fopen("C:/Users/Administrator/Desktop/pic/24/0.txt","r"); // 数字 0  (1)输入数据路径
	end
	
	
	// 读取图像数据，一共 576 行，即 576*20 = 11520 ns = 11.52 ms 读完一张24x24图片 
	// 也是池化模块的计算速度
	always@(posedge clk)
	begin
		if(ivalid == 1)// 当输入有效标志拉高时读取数据时，数据要准备好，否则数据会错位，
		begin
			count_w  <= $fscanf(fp_i,"%b" ,din);
			cnt_line <= cnt_line + 1;
			if(cnt_line == 10'd576) $display("picture read over");
			// $display("%d,%b",count_w,image_in);
		end
	end
	
	// 时钟信号 50MHz
	always #10 clk <= ~clk; 
	
//=======================最大池化计算结果打印=======================
	integer i;
	integer display_line = 0;
	always@(posedge clk)// 缓存有效卷积结果
	begin
		if(ovalid && cnt_pool<144) 
		begin
			//$display("cnt_pool: %d  ", cnt_pool); // 先输出计数，表示缓存到该地址
			// 输入:24*24 -> 输出 12x12=144
			// 输入:8*8   -> 输出 4x4=16
			pool_result_tb[cnt_pool] =  dout; 
			cnt_pool = cnt_pool + 1;
		end
	end
	// 以12x12二维矩阵形式打印卷积结果
	initial
	begin
		# (11540+20); // 等待池化完成
		
		$display("maxpooling complete");
		if(state == 0)
		begin
			for(i=0;i<144;i=i+1)
			begin 
				if(i == 0) $write("%d :", display_line);
				$write("%d ", pool_result_tb[i]); // $write 不会自动换行
				//$write("i:%d %d ", i,pool_result_tb[i]); // $write 不会自动换行
				if((i+1)%12 == 0)// 添加行号并换行,每行 12 个数据
				begin
					$display(" "); 
					display_line = display_line + 1;
					$write("%d :", display_line);
				end
			end	
		end
		else if(state == 1)
		begin
			for(i=0;i<16;i=i+1)
			begin
				$display("%d", pool_result_tb[i]);
			end	
		end
		
		$finish; // 打印完结果后完成仿真
	end
	
endmodule
