module maxpooling
(
    input  clk,
    input  rstn,
    input  ivalid,      // ???????,?????
    input  state,       // 0: ???24*24; 1: 8*8
    input  [7:0] din,   // ???? 8bit
    output ovalid,      // ???????
    output [7:0] dout   // ???? 
);

	reg [7:0] data [0:23];  // ??????,????? 24 or 8
	reg [6:0] ptr;
	reg cnt;                //??0?¡À??¡À????¨¢????data_reg_0,??1?¡À??¡À????¨¢????data_reg_1
	reg [7:0] data_reg_0;
	reg [7:0] data_reg_1;
	reg [7:0] dout_r;
	reg wren;

	// ????
	reg [7:0] din_delay;
	always@(posedge clk)
	if(!rstn)
		din_delay <= 0;
	else
		din_delay <= din;
	// ????????,??2?
	always@(posedge clk)begin
		if(!rstn)
			ptr <= 7'b0000000;
		else
			case(state)
				1'b0:begin
					if(ptr == 7'd48)
						ptr <= 7'd0;
					else 
						if(!ivalid)
							ptr <= ptr;
						else
							ptr <= ptr + 7'd1;
					end
				1'b1:begin
					if(ptr == 7'd16)
						ptr <= 7'd0;
					else 
						if(!ivalid)
							ptr <= ptr;
						else
							ptr <= ptr + 7'd1;
					end               
			endcase
	end
	
	// ???,?????????
	always@(posedge clk or negedge rstn)begin
	if(!rstn)
		cnt <= 0;
	else
		case(state)
			1'b0:begin
					if(ptr <= 7'd23)
						cnt <= 0;
					else
						if(ivalid)
							cnt <= cnt + 1'b1;
						else
							cnt <= cnt;
				end
			1'b1:begin
					if(ptr <= 7'd7)
						cnt <= 0;
					else
						if(ivalid)
							cnt <= cnt + 1'b1;
						else
							cnt <= cnt;
				end
		endcase
	end
	// ??????
	always@(posedge clk)
	begin
		case(state)
		1'b0:begin
			if(ptr <= 7'd24 && ivalid)
				data[ptr-1] <= din_delay;
			end
		1'b1:begin
			if(ptr <= 7'd8 && ivalid) 
				data[ptr-1] <= din;
			end          
		endcase   
	end
	// ????????????????,?????
	always@(*)
	begin
		case({state,cnt})
		2'b00:begin
			if(ptr >= 7'd25)
			begin
				if(din_delay>data[ptr-7'd25])
					data_reg_1 <= din_delay;
				else
					data_reg_1 <= data[ptr-7'd25];
			end
			else
				data_reg_1 <= 0;
			end
		2'b01:begin
			if(ptr >= 7'd25)
			begin
				if(din_delay>data[ptr-7'd25])
					data_reg_0 <= din_delay;
				else
					data_reg_0 <= data[ptr-7'd25];
			end
			else
				data_reg_0 <= 0;
			end
		2'b10:begin
			if(ptr >= 7'd9)
			begin
				if(din>data[ptr-7'd9])
					data_reg_1 <= din;
				else
					data_reg_1 <= data[ptr-7'd9];
			end
			else
				data_reg_1 <= 0;
			end
		2'b11:begin
			if(ptr >= 7'd9)
			begin
				if(din>data[ptr-7'd9])
					data_reg_0 <= din;
				else
					data_reg_0 <= data[ptr-7'd9];
			end
			else
				data_reg_0 <= 0;
			end 
		default:begin
				data_reg_0 <= 0; 
				data_reg_1 <= 0;
				end         
		endcase
	end
	
	// ??????
	always@(posedge clk)begin
		wren <= cnt;
	end

	// reg0 ? reg1 ??,?????
	always@(posedge clk)begin
		if(data_reg_0 > data_reg_1)
			dout_r <= data_reg_0;
		else
			dout_r <= data_reg_1;
	end
	
	assign ovalid = wren; // ????
	assign dout   = dout_r; // ???(????)
	
endmodule
