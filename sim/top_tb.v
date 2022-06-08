`timescale 1ns / 1ns

module cnn_tb;
	reg  clk;
	reg  rstn;
	reg  start_cnn;
	
	reg  image_0_tvalid;                      // 图像
	reg [7:0] image_0_tdata;
	wire image_0_tready;
	
	reg weight_0_tvalid;                      // 卷积模块权重
	reg [7:0] weight_0_tdata;
	wire weight_0_tready;
	
	reg weightfc_0_tvalid;                    // 全连接模块权重
	reg [7:0] weightfc_0_tdata;
	wire weightfc_0_tready;
	
	wire cnn_done;
	
	wire result_0_tvalid;
	wire [31:0] result_0_tdata;
		
	wire [3:0] conv_cnt;
	
	//========================================
	//变量声明
	
	integer i;
	integer fp_w,fp_wfc,fp_i,fp_all,handle;
	integer count_w,count_wfc,count_i,count_img;
	reg [7:0] result [0:2];
	reg [3:0] cnt_image;
	
	reg[10:0] cnt_line_img; // 图片数据读取行数计数
	reg[10:0] cnt_line_w;   // 卷积模块权重读取行数计数
	reg[10:0] cnt_line_fcw; // 全连接模块权重读取行数计数
	
	CNN cnn_acc(
		.clk(clk),
		.rstn(rstn),
		.start_cnn(start_cnn),
		
		.image_tvalid(image_0_tvalid),
		.image_tdata(image_0_tdata),
		.image_tready(image_0_tready),
		
		.weight_tvalid(weight_0_tvalid),
		.weight_tdata(weight_0_tdata),
		.weight_tready(weight_0_tready),
		
		.weightfc_tvalid(weightfc_0_tvalid),
		.weightfc_tdata(weightfc_0_tdata),
		.weightfc_tready(weightfc_0_tready),
		
		.cnn_done(cnn_done),
		
		.result_tdata(result_0_tdata),
		.result_tvalid(result_0_tvalid),
		
		.conv_cnt(conv_cnt)
		);
    
	//===========================================
	// 初始赋值
	initial
	begin
		clk = 0;
		rstn = 0;
		start_cnn = 0;
		image_0_tvalid = 0;
		weight_0_tvalid = 0;
		weightfc_0_tvalid = 0;
		image_0_tdata = 8'hff;
		weight_0_tdata = 8'hff;
		weightfc_0_tdata = 8'hff;
		
		// 读取行数计数清零
		cnt_line_img = 0;
		cnt_line_fcw = 0;
		cnt_line_w   = 0;
		
		#40;
		rstn = 1;
		image_0_tvalid = 1;
		weight_0_tvalid = 1;
		weightfc_0_tvalid = 1;
		
		#40000; 
		start_cnn = 1; 
	end
	
	initial
	begin
		# 120000;
		$finish;
	end
//===================================================================
// 权重和图像数据加载	
	// 文件句柄
	initial
	begin
		fp_w = $fopen("C:/Users/Administrator/Desktop/pic/cnn_test/cw.txt","r"); // 卷积模块权重
		fp_wfc = $fopen("C:/Users/Administrator/Desktop/pic/cnn_test/fcw.txt","r"); // 全连接模块权重
		fp_i = $fopen("C:/Users/Administrator/Desktop/pic/cnn_test/0.txt","r"); // 数字 0 
		//fp_all = $fopen("C:/Users/Administrator/Desktop/pic/cnn_test/images_bin.txt","r"); // 所有测试数据
	end
	
	// 读取图像数据,给滑窗模块
	// 28x28x20 = 15680 ns = 15.68 ms
	always@(posedge clk)
	begin
		if(image_0_tvalid && image_0_tready) // 当滑窗模块开始读取数据时，才输入数据，否则数据错位
		begin
			count_img = $fscanf(fp_i,"%b" ,image_0_tdata);   
			cnt_line_img <= cnt_line_img + 1;
			if(cnt_line_img == 11'd784) $display("picture read over");
			// $display("%d,%b",count_img,image_in);
		end
	end
	
	// 加载卷积模块权重
	always@(posedge clk)
	begin
		if(weight_0_tvalid && weight_0_tready)
		begin
			count_w = $fscanf(fp_w,"%d" ,weight_0_tdata);// 以十进制读取
			cnt_line_w <= cnt_line_w + 1;
			// if(cnt_line_w == 11'd784) $display("weight of conv module read over");
			// $display("%d,%b",count_img,image_in);
		end
	end
	
	// 加载全连接模块权重
	always@(posedge clk)
	begin
		if(weightfc_0_tvalid && weightfc_0_tready)
		begin
			count_wfc = $fscanf(fp_wfc,"%d" ,weightfc_0_tdata);
			cnt_line_fcw <= cnt_line_fcw + 1;
		end
	end
	
	// 结果输出
	always@(posedge clk)
	begin
		if(result_0_tvalid)
			begin
				//$fwrite(handle,"%d\n",$signed(result_tdata));
				$display("%d", result_0_tdata);
			end
	end
	

	/*
	always@(posedge clk or negedge rstn)
	begin
	if(!rstn)
		cnt_image <= 0;
	else if(cnn_done)
		begin
			start_cnn <= 0;
			cnt_image <= cnt_image + 1;
		end
	end
	*/
	

	
//	reg [13:0] cnt;
//	reg [4:0] cnt0;
//	reg cnn_done_ff_0;
//	reg cnn_done_ff_1;
	
	/*
	always@(posedge clk or negedge rstn)
	if(!rstn)
		cnt0 <= 0;
	else
		if(cnt0 == 4'd12)
			cnt0 <= cnt0;
		else if(weight_0_tvalid)
			cnt0 <= cnt0 + 1'b1;
		else
			cnt0 <= 0;
			
	always@(posedge clk)
	if(cnn_done)
		start_cnn <= 0;
	else if(cnt == 14'd10000)
		start_cnn <= 0;
	else 
		if(cnt0 == 14'd2000 || cnn_done_ff_1)
			start_cnn <= 1;
	*/
	
//	always@(posedge clk or negedge rstn)
//	if(!rstn)
//		cnt <= 14'd0;
//	else
//		if(cnn_done)
//			cnt <= cnt + 1'b1;
//		else
//			cnt <= cnt;
//	
//	// 打两拍
//	always@(posedge clk)
//	begin
//		cnn_done_ff_0 <= cnn_done;
//		cnn_done_ff_1 <= cnn_done_ff_0;
//	end
//	
//	always@(posedge clk)
//	begin
//		if(cnt == 14'd10000)
//			begin
//				$fclose(handle);
//			end
//	end
    
	always #10 clk = ~clk ;
endmodule
