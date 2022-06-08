module FIFO_fmap
( 	
    input  clk,
	input  rstn,
	input  [7:0] din,
	input  wr_en,
	input  rd_en,
	input  rd_rst,
	output empty,
	output full,
	output [7:0] dout
);
	reg [7:0] rd_ptr, wr_ptr;
	reg [7:0] mem [0:149];// 深度为 150
	reg [7:0] dout_r;
	integer i;
	
	assign empty = (wr_ptr == rd_ptr);
	assign full  = ((wr_ptr - rd_ptr) == 8'd150);
	
	// 延迟一拍
	reg wr_en_delay;
	always@(posedge clk)begin
		if(!rstn)
			wr_en_delay <= 0;
		else
			wr_en_delay <= wr_en;
	end
	// 读操作
	always @(posedge clk or negedge rstn)begin
		if(!rstn)
			dout_r <= 0;
		else if(rd_en && !empty)
			dout_r <= mem[rd_ptr];
	end
	// 写操作
	always @(posedge clk) 
	begin
	if(rstn && wr_en_delay && !full)
		mem[wr_ptr] <= din;
	end
	
	// 写指针递增	
	always @(posedge clk or negedge rstn) 
	begin
		if(!rstn) 
			wr_ptr <= 0;
		else if(!full && wr_en_delay)// 非满且写使能
			wr_ptr <= wr_ptr + 1;
	end
	
	// 读指针递增
	always @(posedge clk or negedge rstn) 
	begin
		if(!rstn)
			rd_ptr <= 0;
		else
			if(rd_rst)	
				rd_ptr <= 0;
			else if(!empty && rd_en)// 非空且读使能
				rd_ptr <= rd_ptr + 1;
		end
	
	assign dout = dout_r;

endmodule 
