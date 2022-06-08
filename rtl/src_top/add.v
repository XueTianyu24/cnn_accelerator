// 加法器
module add
(
    input clk,
    input signed [31:0] din_0,
    input signed [31:0] din_1,
    input ivalid,
    output ovalid,
    output signed [31:0] dout
);

	reg [31:0] dout_r;
	reg wren;
	reg [31:0] din_0_delay;
	reg wren_delay;
	// 1周期完成计算
	always@(posedge clk)
		din_0_delay <= din_0;
	
	always@(posedge clk)
		dout_r = din_0_delay + din_1;
	
	always@(posedge clk)
	if(ivalid)
		wren <= 1'b1;
	else
		wren <= 1'b0;
	
	always@(posedge clk)
		wren_delay <= wren;
	
	assign ovalid = wren_delay;
	assign dout = dout_r;

endmodule
