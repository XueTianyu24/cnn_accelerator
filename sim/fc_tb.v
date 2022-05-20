`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: jccao
// 
// Create Date: 2022/05/05 08:27:30
// Design Name: 
// Module Name: fc_tb
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


module fc_tb();
	// 输入
	reg clk;
	reg rstn;
	reg ivalid;
	reg signed [7:0] din_0;
	reg signed [7:0] din_1;
	reg signed [7:0] din_2;
	reg signed [7:0] din_3;
	reg signed [7:0] din_4;
	reg signed [7:0] din_5;
	reg signed [7:0] weight;
	reg weight_en;
	// 输出
	wire ovalid;
	wire signed [31:0]dout;
	
	reg[10:0] cnt_line; // 读取行数计数
	integer count_w,fp_i;// 文件指针
	
	integer i_fc;// 循环计数变量
	
	reg signed[31:0] fc_result_tb ; //用于缓存全连接计算结果
	reg [10:0] cnt_fc; // 缓存的全连接模块计算结果计数
	
	// fullconnect module
	fc u_fc(
		.clk(clk),
		.rstn(rstn),
		.ivalid(ivalid),
		.din_0(din_0),
		.din_1(din_1),
		.din_2(din_2),
		.din_3(din_3),
		.din_4(din_4),
		.din_5(din_5),
		.weight(weight),
		.weight_en(weight_en),
		.ovalid(ovalid),
		.dout(dout)
	);
	
	// 初始信号赋值-fullconnect module
	initial
	begin
		clk = 0;
		rstn = 0; // 复位
		cnt_line = 0; //行数清零
		cnt_fc = 0; //计数清零
		ivalid = 0; 
		din_0 = 0;
		din_1 = 0;
		din_2 = 0;
		din_3 = 0;
		din_4 = 0;
		din_5 = 0;
		weight_en = 0;
		weight = 0;
		# 20; // 一周期后填充权重数据，共需要192个时钟周期，192x20
		rstn = 1;
		weight_en = 1;
		weight = 1; // 这里权重全为1
		# (192*20);// 开始填充数据
		// 全连接模块的输入有效信号不能一直为1
		for(i_fc=0;i_fc<32;i_fc=i_fc+1)
		begin
			ivalid = 1; // input valid
			#20;
			ivalid = 0;
			#20;
		end
		
	end
	
	// 读取图片数据
	initial
	begin
		fp_i = $fopen("C:/Users/Administrator/Desktop/pic/16x12/0.txt","r"); // 数字 0  (1)输入数据路径
	end
	
	
	// 读取图像数据，一共 192 行，即 (192/6)*20 = 640 ns = 0.64 ns 读完6x4x4图片 
	// 也是全连接模块的计算速度
	always@(posedge clk)
	begin
		if(ivalid == 1)// 当输入有效标志拉高时读取数据时，数据要准备好，否则数据会错位，
		begin
			count_w  <= $fscanf(fp_i,"%b" ,din_0); // 一次读取6个数据
			count_w  <= $fscanf(fp_i,"%b" ,din_1);
			count_w  <= $fscanf(fp_i,"%b" ,din_2);
			count_w  <= $fscanf(fp_i,"%b" ,din_3);
			count_w  <= $fscanf(fp_i,"%b" ,din_4);
			count_w  <= $fscanf(fp_i,"%b" ,din_5);
			cnt_line <= cnt_line + 6;
			if(cnt_line == 9'd192) $display("picture read over");
			// $display("%d,%b",count_w,image_in);
		end
	end
	
	// 时钟信号 50MHz
	always #10 clk <= ~clk; 
	
//=======================全连接模块计算结果打印=======================
	integer i;
	integer display_line = 0;
	always@(posedge clk)// 缓存有效计算结果
	begin
		if(ovalid) 
		begin
			$display("cnt_fc: %d  ", cnt_fc); // 先输出计数，表示缓存到该地址
			fc_result_tb[cnt_fc] =  dout; 
			$display("fc_result_tb: %d  ", dout);
			cnt_fc = cnt_fc + 1;
		end
	end
	// 仿真
	initial
	begin
		# (20+192*20+32*40+5*20); // 等待全连接模块计算完成
		
		$finish; // 打印完结果后完成仿真
	end
endmodule
