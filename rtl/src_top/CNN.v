module CNN
(
    input wire clk,
    input wire resetn,
    
    input wire start_cnn,
    
    input wire image_tvalid,                      //图像
    output wire image_tready,
    input wire signed [7:0] image_tdata,
    
    input wire weight_tvalid,                      //卷积权重
    output wire weight_tready,
    input wire signed [7:0] weight_tdata,
    
    input wire weightfc_tvalid,                      //全连接权重
    output wire weightfc_tready,
    input wire signed [7:0] weightfc_tdata,
    
    output wire cnn_done,
   
    input wire result_tready,
    output wire result_tvalid,
    output wire signed [31:0] result_tdata,

    output wire [3:0] conv_cnt
/*   
    output wire weight_rerd,              //复位存储卷积层权重参数FIFO的读地址
 
    output wire start_conv_r,

    output wire [3:0] conv_cnt,
    output wire conv_start,
    output wire window_start,
    output wire [5:0] done_conv,

    output wire [31:0] conv_result_0,
    output wire [31:0] conv_result_1,
    output wire [31:0] conv_result_2,
    output wire [31:0] conv_result_3,
    output wire [31:0] conv_result_4,
    output wire [31:0] conv_result_5,
    
    output wire [31:0] add_result_0,

    output wire [31:0] add_result_1,
    output wire [31:0] add_result_2,
    output wire [31:0] add_result_3,
    output wire [31:0] add_result_4,
    output wire [31:0] add_result_5,
   
    output wire [7:0] relu_result_0,

    output wire [7:0] relu_result_1,
    output wire [7:0] relu_result_2,
    output wire [7:0] relu_result_3,
    output wire [7:0] relu_result_4,
    output wire [7:0] relu_result_5,

    output wire [7:0] pooling_result_0,

    output wire [7:0] pooling_result_1,
    output wire [7:0] pooling_result_2,
    output wire [7:0] pooling_result_3,
    output wire [7:0] pooling_result_4,
    output wire [7:0] pooling_result_5,
  
    output wire [31:0] fc_result_0

    output wire [31:0] fc_result_1,
    output wire [31:0] fc_result_2,
    output wire [31:0] fc_result_3,
    output wire [31:0] fc_result_4,
    output wire [31:0] fc_result_5,
    output wire [31:0] fc_result_6,
    output wire [31:0] fc_result_7,
    output wire [31:0] fc_result_8,
    output wire [31:0] fc_result_9,

    output wire [31:0] result_r0_0,

    output wire [31:0] result_r0_1,
    output wire [31:0] result_r0_2,
    output wire [31:0] result_r0_3,
    output wire [31:0] result_r0_4,
    output wire [31:0] result_r0_5,
    output wire [31:0] result_r0_6,
    output wire [31:0] result_r0_7,
    output wire [31:0] result_r0_8,
    output wire [31:0] result_r0_9,
  
    output wire [31:0] result_r1_0

    output wire [31:0] result_r1_1,
    output wire [31:0] result_r1_2,
    output wire [31:0] result_r1_3,
    output wire [31:0] result_r1_4,
    output wire [31:0] result_r1_5,
    output wire [31:0] result_r1_6,
    output wire [31:0] result_r1_7,
    output wire [31:0] result_r1_8,
    output wire [31:0] result_r1_9
*/
);
	reg image_ready;
	reg weight_ready;
	reg weightfc_ready;
	reg result_valid_r;
	reg weight_rerd_r;
	reg cnn_done_r;
	reg signed [31:0] result_data;
	assign image_tready = image_ready;
	assign weight_tready = weight_ready;
	assign weightfc_tready = weightfc_ready;
	assign result_tvalid = result_valid_r;
	assign cnn_done = cnn_done_r;
	assign weight_rerd = weight_rerd_r;
	
	assign result_tdata = result_data;


	//开启标志
	reg start_window;
	reg start_conv;

	//输出有效标志
	wire [5:0] conv_wren;
	wire [5:0] add_wren;
	wire [5:0] relu_wren;
	wire [5:0] pooling_wren;
	wire [9:0] fc_wren;

	//结束标志
	wire [5:0] conv_done;

	//模块输入端口
	wire [39:0] taps;
	reg signed [31:0] add_data [0:5];
	reg signed [31:0] relu_data [0:5];
	
	//模块输出端口
	wire signed [31:0] conv_result [0:5];
	wire signed [31:0] add_result [0:5];
	wire signed [7:0] relu_result [0:5];
	wire signed [7:0] pooling_result [0:5];
	wire signed [31:0] fc_result [0:9];
	reg signed [31:0] result_r0 [0:9];
	reg signed [31:0] result_r1 [0:9];

/*
assign conv_result_0 = conv_result[0];
assign conv_result_1 = conv_result[1];
assign conv_result_2 = conv_result[2];
assign conv_result_3 = conv_result[3];
assign conv_result_4 = conv_result[4];
assign conv_result_5 = conv_result[5];

assign add_result_0 = add_result[0];
assign add_result_1 = add_result[1];
assign add_result_2 = add_result[2];
assign add_result_3 = add_result[3];
assign add_result_4 = add_result[4];
assign add_result_5 = add_result[5];

assign relu_result_0 = relu_result[0];
assign relu_result_1 = relu_result[1];
assign relu_result_2 = relu_result[2];
assign relu_result_3 = relu_result[3];
assign relu_result_4 = relu_result[4];
assign relu_result_5 = relu_result[5];

assign pooling_result_0 = pooling_result[0];
assign pooling_result_1 = pooling_result[1];
assign pooling_result_2 = pooling_result[2];
assign pooling_result_3 = pooling_result[3];
assign pooling_result_4 = pooling_result[4];
assign pooling_result_5 = pooling_result[5];

assign fc_result_0 = fc_result[0];
assign fc_result_1 = fc_result[1];
assign fc_result_2 = fc_result[2];
assign fc_result_3 = fc_result[3];
assign fc_result_4 = fc_result[4];
assign fc_result_5 = fc_result[5];
assign fc_result_6 = fc_result[6];
assign fc_result_7 = fc_result[7];
assign fc_result_8 = fc_result[8];
assign fc_result_9 = fc_result[9];

assign result_r0_0 = result_r0[0];
assign result_r0_1 = result_r0[1];
assign result_r0_2 = result_r0[2];
assign result_r0_3 = result_r0[3];
assign result_r0_4 = result_r0[4];
assign result_r0_5 = result_r0[5];
assign result_r0_6 = result_r0[6];
assign result_r0_7 = result_r0[7];
assign result_r0_8 = result_r0[8];
assign result_r0_9 = result_r0[9];

assign result_r1_0 = result_r1[0];
assign result_r1_1 = result_r1[1];
assign result_r1_2 = result_r1[2];
assign result_r1_3 = result_r1[3];
assign result_r1_4 = result_r1[4];
assign result_r1_5 = result_r1[5];
assign result_r1_6 = result_r1[6];
assign result_r1_7 = result_r1[7];
assign result_r1_8 = result_r1[8];
assign result_r1_9 = result_r1[9];
*/

//计数
reg [3:0] conv_counter = 4'd0;

//feature_map读参数控制
reg [5:0] fmap_rdrst;
reg [5:0] fmap_rden;

//滑窗窗口的输入端口
reg [7:0] image_in;                      

//状态控制
reg state; 

//权重计数
reg [10:0] weight_counter;

//权重缓存
reg signed [7:0] weight_c [0:5];
reg signed [7:0] weight_fc [0:9];

//时钟计数
reg [9:0] cnt;

//第一层feature map缓存端口
reg [5:0] fmap_wren;
wire signed [7:0] fmap_dout [0:5];

//中间参数缓存端口(12个FIFO分别存放第二层的卷积层计算结果)
reg [11:0] s_fifo_valid;
reg signed [31:0] s_fifo_data [0:11];
wire [11:0] s_fifo_ready;
wire [11:0] m_fifo_valid;
wire signed [31:0] m_fifo_data [0:11];
reg [11:0] m_fifo_ready;

reg start_conv_ff_0;
reg start_conv_ff_1;
reg start_conv_ff_2;

wire start_conv_r;



reg [10:0] cnt_fc;
reg [9:0] weight_fc_en;

assign conv_cnt = conv_counter;

reg start_cnn_delay;

always@(posedge clk or negedge resetn)
if(!resetn)
    start_cnn_delay <= 0;
else
    start_cnn_delay <= start_cnn;

///////////////////////////result counter//////////////////////////////

reg [9:0] conv_result_cnt;
always@(posedge clk)
if(!start_conv)
    conv_result_cnt <= 0;
else
    if(conv_wren == 6'b111111)
        conv_result_cnt <= conv_result_cnt + 1;
    else
        conv_result_cnt <= conv_result_cnt;

reg [6:0] add_result_cnt;
always@(posedge clk)
begin
    case(conv_counter)
    4'd4,4'd5,4'd6,4'd7,4'd8,4'd9,4'd10,4'd11,4'd12,4'd13:begin
        if(add_result_cnt == 7'd64)
            add_result_cnt <= 7'd0;
        else
            if(add_wren == 6'b111111)
                add_result_cnt <= add_result_cnt + 7'd1;
            else
                add_result_cnt <= add_result_cnt;
          end
    default:add_result_cnt <= 7'd0;
    endcase
end

reg [7:0] pooling_result_cnt;
always@(posedge clk)
begin
    case(conv_counter)
    4'd1:begin
        if(pooling_result_cnt == 8'd144)
            pooling_result_cnt <= 8'd0;
        else
            if(pooling_wren == 6'b111111)
                pooling_result_cnt <= pooling_result_cnt + 8'd1;
            else
                pooling_result_cnt <= pooling_result_cnt;
         end
    4'd12,4'd13:begin
        if(pooling_result_cnt == 8'd16)
            pooling_result_cnt <= 8'd0;
        else
            if(pooling_wren == 6'b111111)
                pooling_result_cnt <= pooling_result_cnt + 8'd1;
            else
                pooling_result_cnt <= pooling_result_cnt;
          end
    default:pooling_result_cnt <= 8'd0;
    endcase
end

///////////////////////////////////////////////////////////////////////////           
always@(posedge clk or negedge resetn)
begin
    if(!resetn)
        cnt_fc <= 0;
    else
    begin
        if(cnt_fc == 11'd1923)
            cnt_fc <= cnt_fc;
        else if(start_cnn_delay)
            cnt_fc <= cnt_fc + 1'b1;
    end
end

always@(*)
if(cnt_fc <= 10'd1)
    weight_fc_en <= 10'b0000000000;
else if(cnt_fc <= 11'd193)
    weight_fc_en <= 10'b0000000001;
else if(cnt_fc <= 10'd385)
    weight_fc_en <= 10'b0000000010;
else if(cnt_fc <= 11'd577)
    weight_fc_en <= 10'b0000000100;
else if(cnt_fc <= 11'd769)
    weight_fc_en <= 10'b0000001000;
else if(cnt_fc <= 11'd961)
    weight_fc_en <= 10'b0000010000;
else if(cnt_fc <= 11'd1153)
    weight_fc_en <= 10'b0000100000;
else if(cnt_fc <= 11'd1345)
    weight_fc_en <= 10'b0001000000;
else if(cnt_fc <= 11'd1537)
    weight_fc_en <= 10'b0010000000;
else if(cnt_fc <= 11'd1729)
    weight_fc_en <= 10'b0100000000;
else if(cnt_fc <= 11'd1921)
    weight_fc_en <= 10'b1000000000;
else
    weight_fc_en <= 10'b0000000000;

always@(posedge clk or negedge resetn)
if(!resetn)
    weightfc_ready <= 1'b0;
else
    begin
        if(cnt_fc >= 11'd1921)
            weightfc_ready <= 1'b0;
        else if(cnt_fc == 11'd0)
            weightfc_ready <= 1'b0;
        else
            weightfc_ready <= 1'b1;
    end

//**********************卷积循环次数计数***********************// 
reg start_conv_delay;
   
always@(posedge clk or negedge resetn)
if(!resetn)
    start_conv_delay <= 0;
else
    start_conv_delay <= start_conv;

assign start_conv_r = start_conv && (~start_conv_delay);
 
always@(posedge clk) 
if(cnn_done)
    conv_counter <= 4'd0;
else if(start_conv_r)
    conv_counter <= conv_counter + 1;

	//**********0:滑窗窗口大小=28*3，池化层缓存数据个数=12 1：滑窗窗口大小=12*3，池化层缓存数据个数=8************//                      
	always@(*)
		case(conv_counter)
		4'd0,4'd1:state <= 0;
		default:state <= 1;
	endcase

//********************卷积层权重读取***********************// 
always@(posedge clk or negedge resetn)
if(!resetn)
    weight_ready <= 1'b0;
else
    begin
        if(!start_conv || cnt >= 10'd150)
            weight_ready <= 1'b0;
        else
            weight_ready <= 1'b1;
    end                      
    
always@(posedge clk or negedge resetn)
if(!resetn)
    weight_rerd_r <= 0;
else
    if(cnn_done)
        weight_rerd_r <= 1;
    else
        weight_rerd_r <= 0;   

always@(posedge clk or negedge resetn)
if(!resetn)
    weight_counter <= 0;
else if(cnn_done)
    weight_counter <= 0;
else if(weight_tvalid && weight_tready)
    weight_counter <= weight_counter + 1;  
    
	//每次卷积开始运算前，需要150个时钟加载权重;
	always@(*)
	begin
	//**********************第一次卷积循环*********************//
		if(weight_counter <= 11'd24)                                    
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd49)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd74)
			weight_c[2] <= weight_tdata;    
		else if(weight_counter <= 11'd99)
			weight_c[3] <= weight_tdata;
		else if(weight_counter <= 11'd124)
			weight_c[4] <= weight_tdata;
		else if(weight_counter <= 11'd149)
			weight_c[5] <= weight_tdata;
	//**********************第二次卷积循环*********************//
		else if(weight_counter <= 11'd174)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd199)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd224)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd249)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd274)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd299)
			weight_c[5] <= weight_tdata;             
	//**********************第三次卷积循环*********************//        
		else if(weight_counter <= 11'd324)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd349)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd374)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd399)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd424)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd449)
			weight_c[5] <= weight_tdata;                 
	//**********************第四次卷积循环*********************//        
		else if(weight_counter <= 11'd474)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd499)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd524)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd549)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd574)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd599)
			weight_c[5] <= weight_tdata;         
	//**********************第五次卷积循环*********************//               
		else if(weight_counter <= 11'd624)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd649)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd674)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd699)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd724)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd749)
			weight_c[5] <= weight_tdata;        
	//**********************第六次卷积循环*********************//         
		else if(weight_counter <= 11'd774)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd799)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd824)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd849)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd874)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd899)
			weight_c[5] <= weight_tdata; 
	//**********************第七次卷积循环*********************// 
		else if(weight_counter <= 11'd924)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd949)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd974)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd999)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1024)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd1049)
			weight_c[5] <= weight_tdata; 
	//**********************第八次卷积循环*********************// 
		else if(weight_counter <= 11'd1074)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd1099)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd1124)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd1149)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1174)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd1199)
			weight_c[5] <= weight_tdata; 
	//**********************第九次卷积循环*********************// 
		else if(weight_counter <= 11'd1224)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd1249)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd1274)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd1299)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1324)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd1349)
			weight_c[5] <= weight_tdata; 
	//**********************第十次卷积循环*********************// 
		else if(weight_counter <= 11'd1374)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd1399)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd1424)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd1449)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1474)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd1499)
			weight_c[5] <= weight_tdata; 
	//**********************第十一次卷积循环*********************// 
		else if(weight_counter <= 11'd1524)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd1549)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd1574)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd1599)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1624)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd1649)
			weight_c[5] <= weight_tdata; 
	//**********************第十二次卷积循环*********************// 
		else if(weight_counter <= 11'd1674)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd1699)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd1724)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd1749)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1774)
			weight_c[4] <= weight_tdata; 
		else if(weight_counter <= 11'd1799)
			weight_c[5] <= weight_tdata; 
	//**********************第十三次卷积循环*********************// 
		else if(weight_counter <= 11'd1824)
			weight_c[0] <= weight_tdata;
		else if(weight_counter <= 11'd1849)
			weight_c[1] <= weight_tdata;
		else if(weight_counter <= 11'd1874)
			weight_c[2] <= weight_tdata;        
		else if(weight_counter <= 11'd1899)
			weight_c[3] <= weight_tdata;        
		else if(weight_counter <= 11'd1924)
			weight_c[4] <= weight_tdata; 
		else
			weight_c[5] <= weight_tdata;
	end

//全连接层开始前，需要1920个时钟加载权重  
always@(*)
begin
//**********************第一次卷积循环*********************//
    if(cnt_fc <= 11'd1)
        begin
            weight_fc[0] <= 0;
            weight_fc[1] <= 0;
            weight_fc[2] <= 0;
            weight_fc[3] <= 0;
            weight_fc[4] <= 0;
            weight_fc[5] <= 0;
            weight_fc[6] <= 0;
            weight_fc[7] <= 0;
            weight_fc[8] <= 0;
            weight_fc[9] <= 0;
        end    
//*************************全连接层*************************// 
    else if(cnt_fc <= 11'd193)
        weight_fc[0] <= weightfc_tdata;
    else if(cnt_fc <= 11'd385)
        weight_fc[1] <= weightfc_tdata;
    else if(cnt_fc <= 11'd577)
        weight_fc[2] <= weightfc_tdata;
    else if(cnt_fc <= 11'd769)
        weight_fc[3] <= weightfc_tdata;
    else if(cnt_fc <= 11'd961)
        weight_fc[4] <= weightfc_tdata;
    else if(cnt_fc <= 11'd1153)
        weight_fc[5] <= weightfc_tdata;
    else if(cnt_fc <= 11'd1345)
        weight_fc[6] <= weightfc_tdata;
    else if(cnt_fc <= 11'd1537)
        weight_fc[7] <= weightfc_tdata;
    else if(cnt_fc <= 11'd1729)
        weight_fc[8] <= weightfc_tdata;
    else if(cnt_fc <= 11'd1921)
        weight_fc[9] <= weightfc_tdata;
end   

//***********************滑窗输入判断*******************//
always@(posedge clk)
    case(conv_counter)
        4'd1:if(!start_window) image_ready <= 1'b0;
             else image_ready <= 1'b1;
        4'd2,4'd3:if(!start_window) fmap_rden <= 6'b000000;
             else fmap_rden <= 6'b000001;              
        4'd4,4'd5:if(!start_window) fmap_rden <= 6'b000000;
             else fmap_rden <= 6'b000010;
        4'd6,4'd7:if(!start_window) fmap_rden <= 6'b000000;
             else fmap_rden <= 6'b000100;
        4'd8,4'd9:if(!start_window) fmap_rden <= 6'b000000;
             else fmap_rden <= 6'b001000;
        4'd10,4'd11:if(!start_window) fmap_rden <= 6'b000000;
             else fmap_rden <= 6'b010000;
        4'd12,4'd13:if(!start_window) fmap_rden <= 6'b000000;
             else fmap_rden <= 6'b100000;
        default:begin
                image_ready <= 1'b0;
                fmap_rden <= 6'b000000;
                end
    endcase

always@(posedge clk)
    begin
        case(conv_counter)
            4'd2:if(conv_done == 6'b111111) fmap_rdrst <= 6'b000001;
                 else fmap_rdrst <= 6'b000000;            
            4'd4:if(conv_done == 6'b111111) fmap_rdrst <= 6'b000010;
                 else fmap_rdrst <= 6'b000000;
            4'd6:if(conv_done == 6'b111111) fmap_rdrst <= 6'b000100;
                 else fmap_rdrst <= 6'b000000;
            4'd8:if(conv_done == 6'b111111) fmap_rdrst <= 6'b001000;
                 else fmap_rdrst <= 6'b000000;
            4'd10:if(conv_done == 6'b111111) fmap_rdrst <= 6'b010000;
                 else fmap_rdrst <= 6'b000000;
            4'd12:if(conv_done == 6'b111111) fmap_rdrst <= 6'b100000;
                 else fmap_rdrst <= 6'b000000;
            default:fmap_rdrst <= 6'b000000;
        endcase
end

//*********************滑窗输入端口(image_in)***********************//
always@(*)
begin
    case(conv_counter)
        4'd1:image_in <= image_tdata; 
        4'd2,4'd3:image_in <= fmap_dout[0];
        4'd4,4'd5:image_in <= fmap_dout[1];
        4'd6,4'd7:image_in <= fmap_dout[2];
        4'd8,4'd9:image_in <= fmap_dout[3];
        4'd10,4'd11:image_in <= fmap_dout[4];
        4'd12,4'd13:image_in <= fmap_dout[5];
        default:image_in <= 8'b00000000;
    endcase
end
//*****************卷积开始后的延迟时钟计数****************//
always@(posedge clk or negedge resetn)
begin
if(!resetn)
    cnt <= 10'd0;
else
    if(!start_conv)
        cnt <= 10'd0;
    else 
        cnt <= cnt + 10'd1;
end

//*************************滑窗开启***********************//
always@(posedge clk or negedge resetn)
begin
    if(!resetn)
        start_window <= 0;
    else
        if(conv_done == 6'b111111)
            start_window <= 0;
        else
            case(state)
            1'b0:if(cnt == 10'd11) start_window <= 1;
            1'b1:if(cnt == 10'd91) start_window <= 1;
            endcase
end

window window_inst(.clk(clk),.rstn(resetn),.start(start_window),.state(state),.din(image_in),.taps(taps));

//*******************判断卷积模块何时工作******************//

always@(posedge clk or negedge resetn)
begin
if(!resetn)
    start_conv <= 0;
else
    case(conv_counter)
        4'd0:begin
             if(conv_done[0] && conv_done[1] && conv_done[2] && conv_done[3] && conv_done[4] && conv_done[5])
                start_conv <= 0;
             else 
                if(start_cnn_delay && ~cnn_done)
                    start_conv <= 1;
                else
                    start_conv <= start_conv;
             end
        4'd1:begin
             if(conv_done[0] && conv_done[1] && conv_done[2] && conv_done[3] && conv_done[4] && conv_done[5])
                 start_conv <= 0;
             else 
                 if(pooling_result_cnt == 8'd144)
                     start_conv <= 1;
                 else
                     start_conv <= start_conv;
             end
        4'd2,4'd3:begin
                  if(conv_done[0] && conv_done[1] && conv_done[2] && conv_done[3] && conv_done[4] && conv_done[5])
                      start_conv <= 0;
                  else
                      if(conv_result_cnt == 10'd64)
                          start_conv <= 1;
                      else
                          start_conv <= start_conv;
                  end
        4'd4,4'd5,4'd6,4'd7,4'd8,4'd9,4'd10,4'd11:begin
                                                  if(conv_done[0] && conv_done[1] && conv_done[2] && conv_done[3] && conv_done[4] && conv_done[5])
                                                      start_conv <= 0;
                                                  else
                                                      if(add_result_cnt == 7'd64)
                                                          start_conv <= 1;
                                                      else
                                                          start_conv <= start_conv;
                                                  end
        4'd12:begin
              if(conv_done[0] && conv_done[1] && conv_done[2] && conv_done[3] && conv_done[4] && conv_done[5])
                  start_conv <= 0; 
              else
                  if(fc_wren == 10'b1111111111)
                      start_conv <= 1;
                  else
                      start_conv <= start_conv;
              end
        4'd13:begin
              if(conv_done[0] && conv_done[1] && conv_done[2] && conv_done[3] && conv_done[4] && conv_done[5])
                  start_conv <= 0;
              else
                  if(fc_wren == 10'b1111111111)
                      start_conv <= start_conv;
              end
        default:start_conv <= 0;      
    endcase
end

reg [5:0] weight_en = 6'b000000;

always@(*)
begin
    if(cnt == 10'd0)
        weight_en <= 6'b000000;
    else if(cnt <= 10'd25)
        weight_en <= 6'b000001;
    else if(cnt <= 10'd50)
        weight_en <= 6'b000010;
    else if(cnt <= 10'd75)
        weight_en <= 6'b000100;
    else if(cnt <= 10'd100)
        weight_en <= 6'b001000;
    else if(cnt <= 10'd125)
        weight_en <= 6'b010000;
    else if(cnt <= 10'd150)
        weight_en <= 6'b100000;
    else
        weight_en <= 6'b000000;
    end


//********************卷积模块*********************//
genvar i;
generate
    for(i=0;i<=5;i=i+1)
        begin:conv_inst
            conv u_conv(.clk(clk),
                        .rstn(resetn),
                        .start(start_conv),
                        .weight_en(weight_en[i]),
                        .weight(weight_c[i]),
                        .taps(taps),
                        .state(state),
                        .dout(conv_result[i]),
                        .ovalid(conv_wren[i]),
                        .done(conv_done[i]));
            end
endgenerate

//*******************缓存第二层中间结果参数*****************//
always@(*)
case(conv_counter)
    4'd2:if(conv_wren == 6'b111111) s_fifo_valid <= 12'b000000111111;
         else s_fifo_valid <= 12'b000000000000;
    4'd3:if(conv_wren == 6'b111111) s_fifo_valid <= 12'b111111000000;
         else s_fifo_valid <= 12'b000000000000;
    4'd4,4'd6,4'd8,4'd10:if(add_wren == 6'b111111) s_fifo_valid <= 12'b000000111111;
         else s_fifo_valid <= 12'b000000000000;
    4'd5,4'd7,4'd9,4'd11:if(add_wren == 6'b111111) s_fifo_valid <= 12'b111111000000;
         else s_fifo_valid <= 12'b000000000000;
    default:s_fifo_valid <= 12'b000000000000;     
endcase

integer j;

always@(*)
case(conv_counter)
    4'd2:for(j=0;j<=5;j=j+1)
                 s_fifo_data[j] <= conv_result[j];
    4'd3:for(j=0;j<=5;j=j+1)
                 s_fifo_data[j+6] <= conv_result[j];                     
    4'd4,4'd6,4'd8,4'd10:for(j=0;j<=5;j=j+1)
                             s_fifo_data[j] <= add_result[j]; 
    4'd5,4'd7,4'd9,4'd11:for(j=0;j<=5;j=j+1)
                             s_fifo_data[j+6] <= add_result[j];                                                      
    default:for(j=0;j<=11;j=j+1)
                s_fifo_data[j] <= 0;
           
endcase
//****************读出第二层中间结果参数进行累加******************//
always@(*)
case(conv_counter)
    4'd4,4'd6,4'd8,4'd10,4'd12:if(conv_wren == 6'b111111) m_fifo_ready <= 12'b000000111111;
         else if(conv_wren == 6'b000000) m_fifo_ready <= 12'b000000000000;
    4'd5,4'd7,4'd9,4'd11,4'd13:if(conv_wren == 6'b111111) m_fifo_ready <= 12'b111111000000;
         else if(conv_wren == 6'b000000) m_fifo_ready <= 12'b000000000000;
    default:m_fifo_ready <= 12'b000000000000;     
endcase

//********************读出参数(add_data)**********************//
integer k;
always@(posedge clk)
begin
    case(conv_counter)
    4'd4,4'd6,4'd8,4'd10,4'd12:begin
         for(k=0;k<=5;k=k+1)
             if(m_fifo_valid[k] && m_fifo_ready[k])
                 add_data[k] <= m_fifo_data[k];
             else 
                 add_data[k] <= 0;
         end
    4'd5,4'd7,4'd9,4'd11,4'd13:begin
         for(k=0;k<=5;k=k+1)
             if(m_fifo_valid[k+6] && m_fifo_ready[k+6])
                 add_data[k] <= m_fifo_data[k+6];
             else 
                 add_data[k] <= 0;
         end
    default:begin
            for(k=0;k<=5;k=k+1)
                add_data[k] <= 0;
            end
    endcase
end

reg reset_fifo;

always@(posedge clk or negedge resetn)
if(!resetn)
    reset_fifo <= 0;
else
    if(cnn_done)
        reset_fifo <= 0;
    else
        reset_fifo <= 1;
   
//*****************参数缓存******************//
genvar a;
generate
    for(a=0;a<=11;a=a+1)
        begin:fifo_inst
            user_fifo_ip your_instance_name(
              .s_axis_aresetn(reset_fifo),          // input wire s_axis_aresetn
              .s_axis_aclk(clk),                // input wire s_axis_aclk
              .s_axis_tvalid(s_fifo_valid[a]),            // input wire s_axis_tvalid
              .s_axis_tready(s_fifo_ready[a]),            // output wire s_axis_tready
              .s_axis_tdata(s_fifo_data[a]),              // input wire [7 : 0] s_axis_tdata
              .m_axis_tvalid(m_fifo_valid[a]),            // output wire m_axis_tvalid
              .m_axis_tready(m_fifo_ready[a]),            // input wire m_axis_tready
              .m_axis_tdata(m_fifo_data[a])             // output wire [7 : 0] m_axis_tdata
            );
        end
endgenerate

//********************累加模块****************//
reg ivalid_add;
always@(*)
case(conv_counter)
4'd4,4'd5,4'd6,4'd7,4'd8,4'd9,4'd10,4'd11,4'd12,4'd13:if(conv_wren == 6'b111111) ivalid_add <= 1'b1;
                                                        else ivalid_add <= 1'b0;
default:ivalid_add <= 1'b0;
endcase

genvar b;
generate
    for(b=0;b<=5;b=b+1)
        begin:add_inst 
            add u_add(
                .clk(clk),
                .ivalid(ivalid_add),
                .din_0(conv_result[b]),
                .din_1(add_data[b]),
                .ovalid(add_wren[b]),
                .dout(add_result[b])
            );    
        end
endgenerate
    
//******************判断relu模块何时运行**************//
reg ivalid_relu;
always@(*)
case(conv_counter)
4'd1:if(conv_wren == 6'b111111) ivalid_relu <= 1'b1;
     else ivalid_relu <= 1'b0;
4'd12,4'd13:if(add_wren == 6'b111111) ivalid_relu <= 1'b1;
     else ivalid_relu <= 1'b0;
default:ivalid_relu <= 1'b0;
endcase

//******************relu模块数据端口(relu_data)******************//
integer m;
always@(*)
case(conv_counter)
    4'd1:for(m=0;m<=5;m=m+1)
             relu_data[m] <= conv_result[m];
    4'd12,4'd13:for(m=0;m<=5;m=m+1)
             relu_data[m] <= add_result[m];    
    default:for(m=0;m<=5;m=m+1)
             relu_data[m] <= 0;
           
endcase

//********************relu模块*******************//
genvar c;
generate
    for(c=0;c<=5;c=c+1)
        begin:relu_inst 
            relu u_relu(
                .clk(clk),
                .ivalid(ivalid_relu),
                .state(state),
                .din(relu_data[c]),
                .ovalid(relu_wren[c]),
                .dout(relu_result[c])
            );    
        end
endgenerate

//******************池化层******************//
	reg ivalid_pooling;
	always@(*)begin
		case(conv_counter)
			4'd1,4'd12,4'd13:
				if(relu_wren == 6'b111111) 
					ivalid_pooling <= 1'b1;
				else 
					ivalid_pooling <= 1'b0;
			default:ivalid_pooling <= 1'b0;
			endcase
	end
	
	genvar d;
	generate
		for(d=0;d<=5;d=d+1)
			begin:pooling_inst
				maxpooling u_pooling(
					.clk(clk),
					.rstn(resetn),
					.ivalid(ivalid_pooling),
					.state(state),
					.din(relu_result[d]),
					.ovalid(pooling_wren[d]),
					.dout(pooling_result[d])                                     
				);
			end
	endgenerate

//************第一层结果缓存**************//
always@(*)
if(conv_counter == 4'd1 && pooling_wren == 6'b111111)
    fmap_wren <= 6'b111111;
else
    fmap_wren <= 6'b000000;

reg reset_fmap;

always@(posedge clk or negedge resetn)
if(!resetn)
    reset_fmap <= 0;
else
    if(cnn_done)
        reset_fmap <= 0;
    else
        reset_fmap <= 1;

genvar e;
generate
    for(e=0;e<=5;e=e+1)
        begin:fmap_inst
            FIFO_fmap u_FIFO_fmap (
              .clk(clk),
              .rstn(reset_fmap),
              .din(pooling_result[e]),
              .wr_en(fmap_wren[e]),
              .rd_en(fmap_rden[e]),
              .rd_rst(fmap_rdrst[e]),     //reset the address of read data
              .dout(fmap_dout[e]),
              .full(),
              .empty()
            );
        end
endgenerate

//***************全连接层*****************//
reg ivalid_fc;
always@(*)
case(conv_counter)
4'd12,4'd13:if(pooling_wren == 6'b111111) ivalid_fc <= 1;
      else ivalid_fc <= 0;
default:ivalid_fc <= 0;
endcase

genvar f;
generate
    for(f=0;f<10;f=f+1)
        begin:fullconnect_inst
            fc u_fullconnect(
                .clk(clk),
                .rstn(resetn),
                .ivalid(ivalid_fc),
                .din_0(pooling_result[0]),
                .din_1(pooling_result[1]),
                .din_2(pooling_result[2]),
                .din_3(pooling_result[3]),
                .din_4(pooling_result[4]),
                .din_5(pooling_result[5]),
                .weight(weight_fc[f]),
                .weight_en(weight_fc_en[f]),
                .ovalid(fc_wren[f]),
                .dout(fc_result[f])
            );
        end
endgenerate

//*************全连接层计算结果输出*****************//
integer r;
always@(posedge clk)
case(conv_counter)
4'd12:if(fc_wren == 10'b1111111111)
      begin
          result_r0[0] <= fc_result[0];
          result_r0[1] <= fc_result[1];
          result_r0[2] <= fc_result[2];
          result_r0[3] <= fc_result[3];
          result_r0[4] <= fc_result[4];
          result_r0[5] <= fc_result[5];
          result_r0[6] <= fc_result[6];
          result_r0[7] <= fc_result[7];
          result_r0[8] <= fc_result[8];
          result_r0[9] <= fc_result[9];
      end
4'd13:if(fc_wren == 10'b1111111111)
      begin
          result_r1[0] <= fc_result[0] + result_r0[0];
          result_r1[1] <= fc_result[1] + result_r0[1];
          result_r1[2] <= fc_result[2] + result_r0[2];
          result_r1[3] <= fc_result[3] + result_r0[3];
          result_r1[4] <= fc_result[4] + result_r0[4];
          result_r1[5] <= fc_result[5] + result_r0[5];
          result_r1[6] <= fc_result[6] + result_r0[6];
          result_r1[7] <= fc_result[7] + result_r0[7];
          result_r1[8] <= fc_result[8] + result_r0[8];
          result_r1[9] <= fc_result[9] + result_r0[9];
      end
default:begin
          result_r0[0] <= 0;
          result_r0[1] <= 0;
          result_r0[2] <= 0;
          result_r0[3] <= 0;
          result_r0[4] <= 0;
          result_r0[5] <= 0;
          result_r0[6] <= 0;
          result_r0[7] <= 0;
          result_r0[8] <= 0;
          result_r0[9] <= 0;
          result_r1[0] <= 0;
          result_r1[1] <= 0;
          result_r1[2] <= 0;
          result_r1[3] <= 0;
          result_r1[4] <= 0;
          result_r1[5] <= 0;
          result_r1[6] <= 0;
          result_r1[7] <= 0;
          result_r1[8] <= 0;
          result_r1[9] <= 0;
        end
endcase

reg result_valid;
reg [3:0] cnt4;

always@(posedge clk or negedge resetn)
begin
if(!resetn)
    result_valid <= 0;
else
    if(!start_cnn_delay)
        result_valid <= 0;
    else if(cnt4 > 4'd10)
        result_valid <= 0; 
    else if(conv_counter == 4'd13 && fc_wren == 10'b1111111111)
        result_valid <= 1;    
end

wire start_cnn_r;

assign start_cnn_r = start_cnn && ~start_cnn_delay;

always@(posedge clk or negedge resetn)
begin
if(!resetn)
    cnn_done_r <= 0;
else
    if(start_cnn_r)
        cnn_done_r <= 0;
    else if(cnt4 == 4'd10)
        cnn_done_r <= 1;
end
   
always@(posedge clk or negedge resetn)
begin
if(!resetn)
    cnt4 <= 0;
else
    if(!result_valid)
        cnt4 <= 0;
    else
        cnt4 <= cnt4 + 1;
end

always@(posedge clk or negedge resetn)
begin
if(!resetn)
    result_valid_r <= 1'b0;
else    
    if(cnt4 == 4'd0)
        result_valid_r <= 1'b0;
    else if(cnt4 <= 4'd10)
        result_valid_r <= 1'b1;
    else
        result_valid_r <= 1'b0;
end

always@(posedge clk)
begin
if(cnt4 > 4'd0 && cnt4 <= 4'd10)
    result_data <= result_r1[cnt4-1];
else
    result_data <= 0;
end

assign conv_start = start_conv;
assign window_start = start_window;
assign done_conv = conv_done;

endmodule
