`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  jccao
// 
// Create Date: 2022/04/12 14:15:05
// Design Name: 
// Module Name: conv_tb
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

// 例化滑窗模块和卷积模块，进行一般的行为仿真（通过波形进行查看）。
// 控制台按矩阵形式输出计算结果
module conv_tb();
	// 输入
	reg clk;
	reg rstn;
	reg start_conv;
	reg weight_en;
	reg [7:0] weight_c;
	reg state;
	
	reg start_window;
	reg [7:0] image_in;
	// 输出
	wire[31:0]conv_result;
	wire conv_ovalid;
	wire conv_done;
	
	wire [39:0] taps;
	
	parameter cycle = 20; // 时钟周期
	
	// 文件指针
	integer fp_i;
	integer count_w;
	
	// 输入图像 Size 配置
	integer STATE = 0; // 0: 28x28 1:12x12 
	
	// 读取行数计数
	reg[10:0] cnt_line;
	
	//用于卷积计算结果
	reg [31:0] conv_result_r [0:599];
	reg [10:0] cnt_conv; // 缓存的卷积计算结果计数
	
	
	// 滑窗模块
	window window_inst(
		.clk  (clk),
		.rstn (rstn),
		.start(start_window),
		.state(state),
		.din  (image_in),
		.taps (taps)
	);
	
	// 卷积模块
	conv u_conv(
		.clk(clk),
		.rstn(rstn),
		.start(start_conv),
		.weight_en(weight_en),
		.weight(weight_c),
		.taps(taps),
		.state(state),
		.dout(conv_result),
		.ovalid(conv_ovalid),
		.done(conv_done)
		);

	// 初始信号-卷积模块
	initial
	begin
		clk = 0;
		rstn = 0; // 复位
		state = STATE;
		cnt_conv = 0; // 计数清零
		# 20;
		rstn = 1;
		start_conv = 1;
		weight_en  = 1;
		weight_c = 8'd2;
	end
	
	// 初始信号-滑窗模块
	initial
	begin
		cnt_line = 0;// 读取行数清零
		start_window = 0;
		# (20 + 10*cycle);// 比 start_conv 晚10个时钟周期，用于同步权重矩阵与图像数据加载
		start_window = 1; 
	end
	
	// 读取图片数据
	initial
	begin
		fp_i = $fopen("C:/Users/Administrator/Desktop/pic/1/num3_0.txt","r"); // 数字 3
	end
	
	
	// 读取图像数据，一共 784 行，即 784*20 + 20 = 15700 ns = 15.7 ms 读完一张28*28图片 
	always@(posedge clk)
	begin
		if(start_window == 1)// 当滑窗模块开始读取数据时，才输入数据，否则数据错位
		begin
			count_w  <= $fscanf(fp_i,"%b" ,image_in);
			cnt_line <= cnt_line + 1;
			if(cnt_line == 11'd784) $display("picture read over");
			// $display("%d,%b",count_w,image_in);
		end
	end
	
	// 缓存卷积结果到数组（位宽32）并输出log
	integer i;
	integer display_line = 0;
	// 缓存有效卷积结果
	always@(posedge clk)
	begin
		if(conv_ovalid && !conv_done)
		begin
			//$display("cnt_conv: %d  ", cnt_conv); // 先输出计数，表示缓存到该地址
			// 输入:28*28 -> 输出 24x24=576
			// 输入:12*12 -> 输出 8x8=64
			conv_result_r[cnt_conv] =  conv_result; 
			cnt_conv = cnt_conv + 1;
		end
		else 
		begin
			if(conv_done)
			begin
				conv_result_r[cnt_conv] =  conv_result; // 最后一个结果，conv_ovalid 和 conv_done均为 1
				//$display("cnt_conv: %d  ", cnt_conv);
				$display("conv complete");
				if(state == 0)
				begin
					for(i=0;i<576;i=i+1)
					begin 
						if(i == 0) $write("%d :", display_line);
						
						$write("%d ", conv_result_r[i]); // $write 不会自动换行
						
						if((i+1)%24 == 0)// 添加行号并换行
						begin
							$display(" "); // 每行 24 个数据
							display_line = display_line + 1;
							$write("%d :", display_line);
						end
					end	
				end
				else if(state == 1)
				begin
					for(i=0;i<64;i=i+1)
					begin
						$display("%d", conv_result_r[i]);
					end	
				end
				
			end
		end
	end
	
	
	// 时钟信号 50MHz
	always #10 clk <= ~clk; 
//=================================================================================	
//===============================输出BMP格式的图片=================================
// 这里输出 24x24
// 打开示例 bmp 图片获取文件头
integer iIndex = 0;       //输出BMP数据索引 ，0-53：文件头和信息头  54之后：像素数据
integer iBmpWidth;   		//输入BMP 宽度 ,即24
integer iBmpHight;   		//输入BMP 高度，即24
integer iBmpSize;    		//输入BMP字节数 54+24*24*3
integer iDataStartIndex;    //输入BMP 像素数据偏移量
integer iBmpFileId;    	//输入BMP图片
integer iCode;
integer oBmpFileId_1; // 输出BMP图片
reg [7:0] rBmpData [0:2000]; // 缓存图片数据

// 用于卷积计算之后的BMP图片数据
reg [7:0] conv_pixel_data_1 [0:2000];
// 最终写入文件的处理后的BMP图片数据
reg [7:0] conv_BmpData_1 [0:2000];


initial 
begin
	// 打开输入BMP图片
	iBmpFileId = $fopen("C:/Users/Administrator/Desktop/pic/bmp/3.bmp","rb");
	iCode = $fread(rBmpData, iBmpFileId); //将输入BMP图片加载到数组中
	//根据BMP图片文件头的格式，分别计算出图片的宽度/高度/像素数据偏移量/图片字节数
	iBmpWidth 		= {rBmpData[21], rBmpData[20], rBmpData[19], rBmpData[18]};
	iBmpHight 		= {rBmpData[25], rBmpData[24], rBmpData[23], rBmpData[22]};
	iBmpSize  		= {rBmpData[ 5], rBmpData[ 4], rBmpData[ 3], rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13], rBmpData[12], rBmpData[11], rBmpData[10]};
	$fclose(iBmpFileId);
	
	// 打开输出BMP图片
	oBmpFileId_1 = $fopen("C:/Users/Administrator/Desktop/pic/sim/test.bmp","wb+");
	//延迟，等待卷积计算完成 
	#16700;
	
	//输出处理后的图片
	for(iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
			conv_BmpData_1[iIndex] = rBmpData[iIndex];   //文件头和信息头和原BMP图片保持一致，只修改像素数据对应字节
		else
			conv_BmpData_1[iIndex] = conv_pixel_data_1[iIndex-54]; //写入像素数据
	end	
	//将数组中的数据写到输出BMP图片中
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		$fwrite(oBmpFileId_1, "%c" , conv_BmpData_1[iIndex]); //以ASCII写入
	end
	
	//关闭输出BMP图片
	$fclose(oBmpFileId_1);
end

// 写入像素数据到缓存数组中
// Y ——》 RGB（YYY）
integer k;
always@(posedge clk)
begin
	if(cnt_conv == 575) begin
		for(k=0;k<576;k=k+1) 
		begin
			//每次写一个像素数据，即3个字节，所以索引乘3
			conv_pixel_data_1[k*3]   <= conv_result_r[k];  //将图像算法处理后的像素数据写入到对应数组中
			conv_pixel_data_1[k*3+1] <= conv_result_r[k];
			conv_pixel_data_1[k*3+2] <= conv_result_r[k];
		end
	end
end

endmodule
