module conv
#(
    parameter K=5,                   
    parameter S=1                   //??
)

(
    input clk,
    input rstn,
    input start,    		    // 卷积操作开始标志位
    input weight_en,            // 权重读取使能
    input signed [7:0] weight,  // 8bit 权重参数
    input [39:0] taps,          // 滑窗法，一列，5个输入数据（5* 8bit）
    input state,                // 控制信号，state = 0，表示输入为 28*28；state = 1，表示输入为 12*12
    output signed [31:0] dout,  // 卷积计算结果
    output ovalid,
    output done                 // 当前窗口的卷积完成标志位
);

	reg [7:0] weight_addr = 8'd0;
	
	reg [19:0] cnt1;              //工作时钟计数
	reg [9:0]  cnt2;               //???
	reg [9:0]  cnt2s;              //?S???
	reg [9:0]  cnt3s;              //?S???
	reg [31:0] wr_data;           // 卷积计算结果
	reg wren;
	
	reg sum_valid;
	reg sum_valid_ff;
	
	reg [4:0] Ni;     //fmap大小，即输入图像 size
	
	// 输入图像的size
	always@(*)
	if(!state)
		Ni <= 5'd28;
	else
		Ni <= 5'd12;

	
	// 卷积权重矩阵（5*5）
	// 每个权重参数量化为 8bit
	reg signed [7:0] k00,k01,k02,k03,k04,k10,k11,k12,k13,k14,k20,k21,k22,k23,k24,k30,k31,k32,k33,k34,k40,k41,k42,k43,k44;
	// 输入数据与权重矩阵重合部分，5*5
	wire signed [7:0] m04,m14,m24,m34,m44;
	reg signed [7:0] m00,m01,m02,m03,m10,m11,m12,m13,m20,m21,m22,m23,m30,m31,m32,m33,m40,m41,m42,m43;
	// 单个像素数据与对应位置权重相乘的结果
	reg signed [15:0] p00,p01,p02,p03,p04,p10,p11,p12,p13,p14,p20,p21,p22,p23,p24,p30,p31,p32,p33,p34,p40,p41,p42,p43,p44;
	// 七级流水线 暂存值
	reg signed [16:0] sum00,sum01,sum02,sum03,sum04,sum05,sum06,sum07,sum08,sum09,sum10,sum11,sum12,sum13,sum14;
	reg signed [17:0] sum15,sum16,sum17,sum18,sum19,sum20,sum21,sum22,sum23,sum24;
	reg signed [18:0] sum0,sum1,sum2,sum3,sum4;
	reg signed [19:0] sum100,sum101,sum102;
	reg signed [20:0] sum110,sum120;

	// 滑窗法，stride = 1
	assign m04=taps[39:32];
	assign m14=taps[31:24];
	assign m24=taps[23:16];
	assign m34=taps[15:8];
	assign m44=taps[7:0];
	// 一个时钟周期移动一步长，最终得到 24*24 输出图像，所以移动了 576 步，需要576个时钟周期
	always@(posedge clk)  
	begin
		{m00,m01,m02,m03} <= {m01,m02,m03,m04};
		{m10,m11,m12,m13} <= {m11,m12,m13,m14};
		{m20,m21,m22,m23} <= {m21,m22,m23,m24};
		{m30,m31,m32,m33} <= {m31,m32,m33,m34};
		{m40,m41,m42,m43} <= {m41,m42,m43,m44};
	end

	//权重*像素数据
	// 流水线 第一级
	always@(posedge clk)
	begin
		p00<=k00*m00;
		p01<=k01*m01;
		p02<=k02*m02;
		p03<=k03*m03;
		p04<=k04*m04;
		p10<=k10*m10;
		p11<=k11*m11;
		p12<=k12*m12;
		p13<=k13*m13;
		p14<=k14*m14;
		p20<=k20*m20;
		p21<=k21*m21;
		p22<=k22*m22;
		p23<=k23*m23;
		p24<=k24*m24;
		p30<=k30*m30;
		p31<=k31*m31;
		p32<=k32*m32;
		p33<=k33*m33;
		p34<=k34*m34;
		p40<=k40*m40;
		p41<=k41*m41;
		p42<=k42*m42;
		p43<=k43*m43;
		p44<=k44*m44;
	end

/*
//简单流水线
always@(posedge clk)
begin 
    sum0 <= p00+p10+p20+p30+p40;
    sum1 <= p01+p11+p21+p31+p41;
    sum2 <= p02+p12+p22+p32+p42;
    sum3 <= p03+p13+p23+p33+p43;
    sum4 <= p04+p14+p24+p34+p44;
end
*/
	// 流水线 第二级
	always@(posedge clk)
	begin
		sum00<=p00+p10;
		sum01<=p20+p30;
		sum02<=p40;
		sum03<=p01+p11;
		sum04<=p21+p31;
		sum05<=p41;
		sum06<=p02+p12;
		sum07<=p22+p32;
		sum08<=p42;
		sum09<=p03+p13;
		sum10<=p23+p33;
		sum11<=p43;
		sum12<=p04+p14;
		sum13<=p24+p34;
		sum14<=p44;
	end

	// 流水线 第三级
	always@(posedge clk)
	begin
		sum15<=sum00+sum01;
		sum16<=sum02;
		sum17<=sum03+sum04;
		sum18<=sum05;
		sum19<=sum06+sum07;
		sum20<=sum08;
		sum21<=sum09+sum10;
		sum22<=sum11;
		sum23<=sum12+sum13;
		sum24<=sum14;
	end

	// 流水线 第四级
	always@(posedge clk)
	begin
		sum0<=sum15+sum16;
		sum1<=sum17+sum18;
		sum2<=sum19+sum20;
		sum3<=sum21+sum22;
		sum4<=sum23+sum24;
	end
	
	// 流水线 第五级
	always@(posedge clk)
	begin
		sum100 <= sum0 + sum1;
		sum101 <= sum2 + sum3;
		sum102 <= sum4;
	end
	
	// 流水线 第六级
	always@(posedge clk)
	begin
		sum110 <= sum100 + sum101;
		sum120 <= sum102;
	end
	
	// 流水线 第七级
	always@(posedge clk)begin
		wr_data <= sum110 + sum120;
	end

	// 从卷积开始计数25个时钟周期，用于读取权重。
	always@(posedge clk or negedge rstn)
	begin
		if(!rstn || !start) // start = 1 且 weight_en = 1启动
			weight_addr <= 0;
		else
			if(weight_addr == 8'd25)
				weight_addr <= weight_addr;
			else
				if(!weight_en)
					weight_addr <= weight_addr;
				else
					weight_addr <= weight_addr + 1;
	end

	//5*5 权重矩阵，读取缓存的权重
	always@(posedge clk)
	begin
		case(weight_addr)
			8'd0:	k00 <= weight;
			8'd1:	k01 <= weight;
			8'd2:	k02 <= weight;
			8'd3:	k03 <= weight;
			8'd4:	k04 <= weight;
			8'd5:	k10 <= weight;
			8'd6:	k11 <= weight;
			8'd7:	k12 <= weight;
			8'd8:	k13 <= weight;
			8'd9:	k14 <= weight;
			8'd10:  k20 <= weight;
			8'd11:  k21 <= weight;
			8'd12:  k22 <= weight;
			8'd13:  k23 <= weight;
			8'd14:  k24 <= weight;
			8'd15:  k30 <= weight;
			8'd16:  k31 <= weight;
			8'd17:  k32 <= weight;
			8'd18:  k33 <= weight;
			8'd19:  k34 <= weight;
			8'd20:  k40 <= weight;
			8'd21:  k41 <= weight;
			8'd22:  k42 <= weight;
			8'd23:  k43 <= weight;
			8'd24:  k44 <= weight;
			default:;
		endcase
	end

	//conv操作工作时钟计数 
	always@(posedge clk)
	begin
		if(start)
			cnt1<=cnt1+1'd1;
		else
			cnt1<=19'd0;
	end

	//列计数
	always@(posedge clk)
	if(sum_valid)
		if(cnt2==Ni-1)
			cnt2<=10'd0;
		else
			cnt2<=cnt2+10'd1;
	else
		cnt2<=10'd0;

	//卷积列步长   
	always@(posedge clk)
	if(sum_valid)
		if(cnt2==Ni-1)
			if(cnt3s==S-1)
				cnt3s<=10'd0;
			else
				cnt3s<=cnt3s+1'd1;
		else
		cnt3s<=cnt3s;
	else
	cnt3s<=10'd0;

	//行步长
	always@(posedge clk)
	if(sum_valid)
		if(cnt2 == Ni-1|| cnt2s == S-1)
			cnt2s<=10'd0;
		else 
			cnt2s<=cnt2s+10'd1;
	else
		cnt2s<=10'd0;
      
	//???    
	always@(posedge clk)
	begin
		if(sum_valid && cnt2<Ni-K+1 && cnt2s==0 && cnt3s==0)
			wren<=1'b1;
		else
			wren<=1'b0;
	end

	/*
	//???? 
	always@(posedge clk)
	begin
		if(!start)
			sum_valid<=1'b0;
		else if(cnt1==8'd153)   //??(150+K-1+1+2-2)????????????????             150:6????????????????  2?????????????????  1:???????  K-1:???????????????   -2:??????     
			sum_valid<=1'b1;
		else
			case(state)         //state1:28x28 state2:12x12
				1'b0:if(cnt1==10'd821)       //??(150+2+1+(N-k+1)i*(Ni-k+1)-1)??????????????????????????????sum_valid??
						sum_valid<=1'b0;
				1'b1:if(cnt1==10'd247)
						sum_valid<=1'b0;
			endcase
	end
	*/
	always@(posedge clk)
	begin
		if(!start)
			sum_valid<=1'b0;
		else
			case(state)
			// 输入图像 Size 为 28*28
			1'b0:if(cnt1==10'd830)       //??(150+2+1+(N-k+1)i*(Ni-k+1)-1)??????????????????????????????sum_valid??
					sum_valid<=1'b0;
				else if(cnt1==8'd162)
					sum_valid<=1'b1;
			// 输入图像 Size 为 12*12		
			1'b1:if(cnt1==10'd255)
					sum_valid<=1'b0;   
				else if(cnt1==8'd163)
					sum_valid<=1'b1;    
			endcase
	end
	
	// 延迟一拍，用于采沿，判断卷积是否完成
	always@(posedge clk)begin
		sum_valid_ff <= sum_valid; 
	end
	
	assign done = ~sum_valid && sum_valid_ff;  // 采样下降沿，出现即表示当前窗口的卷积完成标志位
	assign ovalid = wren;
	assign dout = wr_data; // 卷积计算结果

endmodule