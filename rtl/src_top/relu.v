module relu
(
    input clk,
    input signed [31:0] din,  
    input ivalid,
    input state,
    output reg ovalid,   
    output reg signed [7:0] dout
);

	reg wren;
	reg [31:0] dout_r;
	reg [31:0] dout_delay;
	
	// ????,?????
	always@(posedge clk)begin
		if(ivalid)
			wren <= 1'b1;
		else
			wren <= 1'b0;
	end

	// ?????,?0????
	always@(posedge clk)begin
		if(din[31])
			dout_r <= 0;
		else
			dout_r <= din;
	end
	// ????
	always@(posedge clk)begin
		dout_delay <= dout_r;
	end
	
	/*    
	assign dout = (state)?(dout_delay >>> 10):(dout_r >>> 10);
	assign ovalid = wren;
	*/
	always@(posedge clk)begin
		if(state)
			dout <= (dout_delay >>> 10);
		else
			dout <= (dout_r >>> 10); 
	end
	
	always@(posedge clk)begin
		ovalid <= wren;
	end
	
endmodule
