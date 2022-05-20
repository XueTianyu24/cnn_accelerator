`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JCCAO
// 
// Create Date: 2022/04/12 18:12:46
// Design Name: 
// Module Name: window_tb
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


module window_tb();
	// 输入
	reg clk;
	reg resetn;
	reg start_window;
	reg state;
	reg[7:0] image_in;
	// 输出
	wire[39:0] taps;
	
	// 文件指针
	integer fp_i;
	integer count_w;
	
	// 读取行数计数
	reg[10:0] cnt_line;
	
	// 滑窗模块
	window window_inst(
		.clk  (clk),
		.rstn (resetn),
		.start(start_window),
		.state(state),
		.din  (image_in),
		.taps (taps)
	);
	
	// 读取图片数据
	initial
	begin
		fp_i = $fopen("C:/Users/Administrator/Desktop/pic/1/num3_0.txt","r"); // 数字 3
	end
	// 初始信号
	initial
	begin
		cnt_line = 0;// 读取行数清零
		clk = 0;
		start_window = 0;
		state = 0;
		# 20;
		start_window = 1;
	end
	
	// 读取图像数据，一共 784 行，即 784*20 + 20 = 15700 ns = 15.7 ms 读完一张28*28图片 
	always@(posedge clk)
	begin
		begin
			count_w  <= $fscanf(fp_i,"%b" ,image_in);
			cnt_line <= cnt_line + 1;
			if(cnt_line == 11'd784) $display("picture read over");
			// $display("%d,%b",count_w,image_in);
		end
	end
	
	// 时钟信号 50MHz
	always #10 clk <= ~clk; 
endmodule
