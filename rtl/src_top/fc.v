// 全连接层
// 一个神经元
module fc
(
    input clk,
    input rstn,
    input ivalid,
    input signed [7:0] din_0,    
    input signed [7:0] din_1,
    input signed [7:0] din_2,
    input signed [7:0] din_3,
    input signed [7:0] din_4,
    input signed [7:0] din_5,
    input signed [7:0] weight,       
    input weight_en, // 权重读取使能
    output ovalid,
    output signed [31:0] dout
);

	reg [7:0] weight_addr;
	
	reg signed [7:0] w [0:191];
	
	reg [4:0] cnt;            
	reg [4:0] cnt0;
	
	
	reg sum_valid;
	reg wren;
	reg signed [15:0] p0,p1,p2,p3,p4,p5;
	reg signed [16:0] sum00,sum01,sum02;
	reg signed [17:0] sum10,sum11;
	reg signed [18:0] sum;
	reg signed [22:0] dout_r;
	
	reg ivalid_ff_0,ivalid_ff_1,ivalid_ff_2,ivalid_ff_3;
	
	//??
	always@(posedge clk)
	begin
		if(!rstn)
			dout_r <= 0;
		else if(wren)
			dout_r <= 0;
		else if(ivalid_ff_3)
			dout_r <= dout_r + sum; // 累加求最终总和
		else
			dout_r <= dout_r;
	end 
	// 打拍采沿
	always@(posedge clk)
	begin
		ivalid_ff_0 <= ivalid;
		ivalid_ff_1 <= ivalid_ff_0;
		ivalid_ff_2 <= ivalid_ff_1;
		ivalid_ff_3 <= ivalid_ff_2;
	end
	
	always@(posedge clk)
	begin
		if(ivalid_ff_2 && ~ivalid_ff_1)// 采样下降沿
			sum_valid <= 1; // 即读一次输入数据，计算一次
		else
			sum_valid <= 0; 
	end
	
	always@(posedge clk or negedge rstn)
	begin
	if(!rstn)
		cnt0 <= 0;
	else
		begin
			if(wren || cnt0 == 5'd16)
				cnt0 <= 0;
			else
				if(sum_valid)// 输入来一次相乘累加一次
					cnt0 <= cnt0 + 1;
				else
					cnt0 <= cnt0;
		end
	end
	
	// 输出使能，cnt到16表示计算结束
	always@(posedge clk)
	begin
		if(cnt0 == 5'd16)
			wren <= 1;
		else
			wren <= 0;
	end
	
	//fullconnect 计算计数，cnt:0~15
	always@(posedge clk)
	begin
		if(!rstn)
		cnt <=0;
		else
			if(cnt == 5'd16 || wren)
				cnt <= 0;
			else 
				if(ivalid_ff_0)
					cnt <= cnt + 1;
				else
					cnt <= cnt;
	end
	
	// 权重地址每时钟周期递增+1
	always@(posedge clk)
	begin
		if(!rstn)
			weight_addr <= 8'd0;
		else begin
			if(weight_addr == 8'd192)
				weight_addr <= weight_addr;
			else 
				if(weight_en)
					weight_addr <= weight_addr + 1;
				else
					weight_addr <= weight_addr;
		end
	end
		
	// 权重读取，共192
	always@(posedge clk)
	begin
		case(weight_addr)
			8'd0:w[0]<=weight;
			8'd1:w[1]<=weight;
			8'd2:w[2]<=weight;
			8'd3:w[3]<=weight;
			8'd4:w[4]<=weight;
			8'd5:w[5]<=weight;
			8'd6:w[6]<=weight;
			8'd7:w[7]<=weight;
			8'd8:w[8]<=weight;
			8'd9:w[9]<=weight;
			8'd10:w[10]<=weight;
			8'd11:w[11]<=weight;
			8'd12:w[12]<=weight;
			8'd13:w[13]<=weight;
			8'd14:w[14]<=weight;
			8'd15:w[15]<=weight;
			8'd16:w[16]<=weight;
			8'd17:w[17]<=weight;
			8'd18:w[18]<=weight;
			8'd19:w[19]<=weight;
			8'd20:w[20]<=weight;
			8'd21:w[21]<=weight;
			8'd22:w[22]<=weight;
			8'd23:w[23]<=weight;
			8'd24:w[24]<=weight;
			8'd25:w[25]<=weight;
			8'd26:w[26]<=weight;
			8'd27:w[27]<=weight;
			8'd28:w[28]<=weight;
			8'd29:w[29]<=weight;
			8'd30:w[30]<=weight;
			8'd31:w[31]<=weight;
			8'd32:w[32]<=weight;
			8'd33:w[33]<=weight;
			8'd34:w[34]<=weight;
			8'd35:w[35]<=weight;
			8'd36:w[36]<=weight;
			8'd37:w[37]<=weight;
			8'd38:w[38]<=weight;
			8'd39:w[39]<=weight;
			8'd40:w[40]<=weight;
			8'd41:w[41]<=weight;
			8'd42:w[42]<=weight;
			8'd43:w[43]<=weight;
			8'd44:w[44]<=weight;
			8'd45:w[45]<=weight;
			8'd46:w[46]<=weight;
			8'd47:w[47]<=weight;
			8'd48:w[48]<=weight;
			8'd49:w[49]<=weight;
			8'd50:w[50]<=weight;
			8'd51:w[51]<=weight;
			8'd52:w[52]<=weight;
			8'd53:w[53]<=weight;
			8'd54:w[54]<=weight;
			8'd55:w[55]<=weight;
			8'd56:w[56]<=weight;
			8'd57:w[57]<=weight;
			8'd58:w[58]<=weight;
			8'd59:w[59]<=weight;
			8'd60:w[60]<=weight;
			8'd61:w[61]<=weight;
			8'd62:w[62]<=weight;
			8'd63:w[63]<=weight;
			8'd64:w[64]<=weight;
			8'd65:w[65]<=weight;
			8'd66:w[66]<=weight;
			8'd67:w[67]<=weight;
			8'd68:w[68]<=weight;
			8'd69:w[69]<=weight;
			8'd70:w[70]<=weight;
			8'd71:w[71]<=weight;
			8'd72:w[72]<=weight;
			8'd73:w[73]<=weight;
			8'd74:w[74]<=weight;
			8'd75:w[75]<=weight;
			8'd76:w[76]<=weight;
			8'd77:w[77]<=weight;
			8'd78:w[78]<=weight;
			8'd79:w[79]<=weight;
			8'd80:w[80]<=weight;
			8'd81:w[81]<=weight;
			8'd82:w[82]<=weight;
			8'd83:w[83]<=weight;
			8'd84:w[84]<=weight;
			8'd85:w[85]<=weight;
			8'd86:w[86]<=weight;
			8'd87:w[87]<=weight;
			8'd88:w[88]<=weight;
			8'd89:w[89]<=weight;
			8'd90:w[90]<=weight;
			8'd91:w[91]<=weight;
			8'd92:w[92]<=weight;
			8'd93:w[93]<=weight;
			8'd94:w[94]<=weight;
			8'd95:w[95]<=weight;
			8'd96:w[96]<=weight;
			8'd97:w[97]<=weight;
			8'd98:w[98]<=weight;
			8'd99:w[99]<=weight;
			8'd100:w[100]<=weight;
			8'd101:w[101]<=weight;
			8'd102:w[102]<=weight;
			8'd103:w[103]<=weight;
			8'd104:w[104]<=weight;
			8'd105:w[105]<=weight;
			8'd106:w[106]<=weight;
			8'd107:w[107]<=weight;
			8'd108:w[108]<=weight;
			8'd109:w[109]<=weight;
			8'd110:w[110]<=weight;
			8'd111:w[111]<=weight;
			8'd112:w[112]<=weight;
			8'd113:w[113]<=weight;
			8'd114:w[114]<=weight;
			8'd115:w[115]<=weight;
			8'd116:w[116]<=weight;
			8'd117:w[117]<=weight;
			8'd118:w[118]<=weight;
			8'd119:w[119]<=weight;
			8'd120:w[120]<=weight;
			8'd121:w[121]<=weight;
			8'd122:w[122]<=weight;
			8'd123:w[123]<=weight;
			8'd124:w[124]<=weight;
			8'd125:w[125]<=weight;
			8'd126:w[126]<=weight;
			8'd127:w[127]<=weight;
			8'd128:w[128]<=weight;
			8'd129:w[129]<=weight;
			8'd130:w[130]<=weight;
			8'd131:w[131]<=weight;
			8'd132:w[132]<=weight;
			8'd133:w[133]<=weight;
			8'd134:w[134]<=weight;
			8'd135:w[135]<=weight;
			8'd136:w[136]<=weight;
			8'd137:w[137]<=weight;
			8'd138:w[138]<=weight;
			8'd139:w[139]<=weight;
			8'd140:w[140]<=weight;
			8'd141:w[141]<=weight;
			8'd142:w[142]<=weight;
			8'd143:w[143]<=weight;
			8'd144:w[144]<=weight;
			8'd145:w[145]<=weight;
			8'd146:w[146]<=weight;
			8'd147:w[147]<=weight;
			8'd148:w[148]<=weight;
			8'd149:w[149]<=weight;
			8'd150:w[150]<=weight;
			8'd151:w[151]<=weight;
			8'd152:w[152]<=weight;
			8'd153:w[153]<=weight;
			8'd154:w[154]<=weight;
			8'd155:w[155]<=weight;
			8'd156:w[156]<=weight;
			8'd157:w[157]<=weight;
			8'd158:w[158]<=weight;
			8'd159:w[159]<=weight;
			8'd160:w[160]<=weight;
			8'd161:w[161]<=weight;
			8'd162:w[162]<=weight;
			8'd163:w[163]<=weight;
			8'd164:w[164]<=weight;
			8'd165:w[165]<=weight;
			8'd166:w[166]<=weight;
			8'd167:w[167]<=weight;
			8'd168:w[168]<=weight;
			8'd169:w[169]<=weight;
			8'd170:w[170]<=weight;
			8'd171:w[171]<=weight;
			8'd172:w[172]<=weight;
			8'd173:w[173]<=weight;
			8'd174:w[174]<=weight;
			8'd175:w[175]<=weight;
			8'd176:w[176]<=weight;
			8'd177:w[177]<=weight;
			8'd178:w[178]<=weight;
			8'd179:w[179]<=weight;
			8'd180:w[180]<=weight;
			8'd181:w[181]<=weight;
			8'd182:w[182]<=weight;
			8'd183:w[183]<=weight;
			8'd184:w[184]<=weight;
			8'd185:w[185]<=weight;
			8'd186:w[186]<=weight;
			8'd187:w[187]<=weight;
			8'd188:w[188]<=weight;
			8'd189:w[189]<=weight;
			8'd190:w[190]<=weight;
			8'd191:w[191]<=weight;
			default:;
		endcase
	end
	
	//state: 0:0-96, 1: 97-191
	reg state;
	always@(posedge clk or negedge rstn)
	begin
	if(!rstn)
		state <= 0;
	else
		if(wren) 
			state <= state + 1;
	end
			
	//???
	/*
	always@(posedge clk)
	begin
	case({state,cnt[3:0]})
	5'b00000:begin
				p0 <= w[0]*din_0;    
				p1 <= w[16]*din_1; 
				p2 <= w[32]*din_2;
				p3 <= w[48]*din_3; 
				p4 <= w[64]*din_4; 
				p5 <= w[80]*din_5;
			end
	5'b00001:begin
				p0 <= w[1]*din_0;    
				p1 <= w[17]*din_1; 
				p2 <= w[33]*din_2; 
				p3 <= w[49]*din_3; 
				p4 <= w[65]*din_4; 
				p5 <= w[81]*din_5;
			end
	5'b00010:begin
				p0 <= w[2]*din_0;    
				p1 <= w[18]*din_1;
				p2 <= w[34]*din_2; 
				p3 <= w[50]*din_3; 
				p4 <= w[66]*din_4;
				p5 <= w[82]*din_5;
			end
	5'b00011:begin
				p0 <= w[3]*din_0;    
				p1 <= w[19]*din_1;
				p2 <= w[35]*din_2; 
				p3 <= w[51]*din_3; 
				p4 <= w[67]*din_4;
				p5 <= w[83]*din_5;
			end
	5'b00100:begin
				p0 <= w[4]*din_0;    
				p1 <= w[20]*din_1;
				p2 <= w[36]*din_2; 
				p3 <= w[52]*din_3; 
				p4 <= w[68]*din_4;
				p5 <= w[84]*din_5;
			end
	5'b00101:begin
				p0 <= w[5]*din_0;    
				p1 <= w[21]*din_1;
				p2 <= w[37]*din_2; 
				p3 <= w[53]*din_3; 
				p4 <= w[69]*din_4;
				p5 <= w[85]*din_5;
			end
	5'b00110:begin
				p0 <= w[6]*din_0;    
				p1 <= w[22]*din_1;
				p2 <= w[38]*din_2; 
				p3 <= w[54]*din_3; 
				p4 <= w[70]*din_4;
				p5 <= w[86]*din_5;
			end
	5'b00111:begin
				p0 <= w[7]*din_0;    
				p1 <= w[23]*din_1;
				p2 <= w[39]*din_2; 
				p3 <= w[55]*din_3; 
				p4 <= w[71]*din_4;
				p5 <= w[87]*din_5;
			end
	5'b01000:begin
				p0 <= w[8]*din_0;    
				p1 <= w[24]*din_1;
				p2 <= w[40]*din_2; 
				p3 <= w[56]*din_3; 
				p4 <= w[72]*din_4;
				p5 <= w[88]*din_5;
			end
	5'b01001:begin
				p0 <= w[9]*din_0;    
				p1 <= w[25]*din_1;
				p2 <= w[41]*din_2; 
				p3 <= w[57]*din_3; 
				p4 <= w[73]*din_4;
				p5 <= w[89]*din_5;
			end
	5'b01010:begin
				p0 <= w[10]*din_0;    
				p1 <= w[26]*din_1;
				p2 <= w[42]*din_2; 
				p3 <= w[58]*din_3; 
				p4 <= w[74]*din_4;
				p5 <= w[90]*din_5;
			end
	5'b01011:begin
				p0 <= w[11]*din_0;    
				p1 <= w[27]*din_1;
				p2 <= w[43]*din_2; 
				p3 <= w[59]*din_3; 
				p4 <= w[75]*din_4;
				p5 <= w[91]*din_5;
			end
	5'b01100:begin
				p0 <= w[12]*din_0;    
				p1 <= w[28]*din_1;
				p2 <= w[44]*din_2; 
				p3 <= w[60]*din_3; 
				p4 <= w[76]*din_4;
				p5 <= w[92]*din_5;
			end
	5'b01101:begin
				p0 <= w[13]*din_0;    
				p1 <= w[29]*din_1;
				p2 <= w[45]*din_2; 
				p3 <= w[61]*din_3; 
				p4 <= w[77]*din_4;
				p5 <= w[93]*din_5;
			end
	5'b01110:begin
				p0 <= w[14]*din_0;    
				p1 <= w[30]*din_1;
				p2 <= w[46]*din_2; 
				p3 <= w[62]*din_3; 
				p4 <= w[78]*din_4;
				p5 <= w[94]*din_5;
			end
	5'b01111:begin
				p0 <= w[15]*din_0;    
				p1 <= w[31]*din_1;
				p2 <= w[47]*din_2; 
				p3 <= w[63]*din_3; 
				p4 <= w[79]*din_4;
				p5 <= w[95]*din_5;
			end
	5'b10000:begin
				p0 <= w[96]*din_0;    
				p1 <= w[112]*din_1; 
				p2 <= w[128]*din_2; 
				p3 <= w[144]*din_3; 
				p4 <= w[160]*din_4; 
				p5 <= w[176]*din_5;    
			end
	5'b10001:begin
				p0 <= w[97]*din_0;    
				p1 <= w[113]*din_1; 
				p2 <= w[129]*din_2; 
				p3 <= w[145]*din_3; 
				p4 <= w[161]*din_4; 
				p5 <= w[177]*din_5;
			end
	5'b10010:begin
				p0 <= w[98]*din_0;    
				p1 <= w[114]*din_1; 
				p2 <= w[130]*din_2; 
				p3 <= w[146]*din_3; 
				p4 <= w[162]*din_4; 
				p5 <= w[178]*din_5;            
			end
	5'b10011:begin
				p0 <= w[99]*din_0;    
				p1 <= w[115]*din_1; 
				p2 <= w[131]*din_2; 
				p3 <= w[147]*din_3; 
				p4 <= w[163]*din_4; 
				p5 <= w[179]*din_5;            
			end
	5'b10100:begin
				p0 <= w[100]*din_0;    
				p1 <= w[116]*din_1; 
				p2 <= w[132]*din_2; 
				p3 <= w[148]*din_3; 
				p4 <= w[164]*din_4; 
				p5 <= w[180]*din_5;            
			end
	5'b10101:begin
				p0 <= w[101]*din_0;    
				p1 <= w[117]*din_1; 
				p2 <= w[133]*din_2; 
				p3 <= w[149]*din_3; 
				p4 <= w[165]*din_4; 
				p5 <= w[181]*din_5;            
			end
	5'b10110:begin
				p0 <= w[102]*din_0;    
				p1 <= w[118]*din_1; 
				p2 <= w[134]*din_2; 
				p3 <= w[150]*din_3; 
				p4 <= w[166]*din_4; 
				p5 <= w[182]*din_5;            
			end
	5'b10111:begin
				p0 <= w[103]*din_0;    
				p1 <= w[119]*din_1; 
				p2 <= w[135]*din_2; 
				p3 <= w[151]*din_3; 
				p4 <= w[167]*din_4; 
				p5 <= w[183]*din_5;            
			end
	5'b11000:begin
				p0 <= w[104]*din_0;    
				p1 <= w[120]*din_1; 
				p2 <= w[136]*din_2; 
				p3 <= w[152]*din_3; 
				p4 <= w[168]*din_4; 
				p5 <= w[184]*din_5;            
			end
	5'b11001:begin
				p0 <= w[105]*din_0;    
				p1 <= w[121]*din_1; 
				p2 <= w[137]*din_2; 
				p3 <= w[153]*din_3; 
				p4 <= w[169]*din_4; 
				p5 <= w[185]*din_5;            
			end
	5'b11010:begin
				p0 <= w[106]*din_0;    
				p1 <= w[122]*din_1; 
				p2 <= w[138]*din_2; 
				p3 <= w[154]*din_3; 
				p4 <= w[170]*din_4; 
				p5 <= w[186]*din_5;            
			end
	5'b11011:begin
				p0 <= w[107]*din_0;    
				p1 <= w[123]*din_1; 
				p2 <= w[139]*din_2; 
				p3 <= w[155]*din_3; 
				p4 <= w[171]*din_4; 
				p5 <= w[187]*din_5;            
			end
	5'b11100:begin
				p0 <= w[108]*din_0;    
				p1 <= w[124]*din_1; 
				p2 <= w[140]*din_2; 
				p3 <= w[156]*din_3; 
				p4 <= w[172]*din_4; 
				p5 <= w[188]*din_5;            
			end
	5'b11101:begin
				p0 <= w[109]*din_0;    
				p1 <= w[125]*din_1; 
				p2 <= w[141]*din_2; 
				p3 <= w[157]*din_3; 
				p4 <= w[173]*din_4; 
				p5 <= w[189]*din_5;            
			end
	5'b11110:begin
				p0 <= w[110]*din_0;    
				p1 <= w[126]*din_1; 
				p2 <= w[142]*din_2; 
				p3 <= w[158]*din_3; 
				p4 <= w[174]*din_4; 
				p5 <= w[190]*din_5;            
			end
	5'b11111:begin
				p0 <= w[111]*din_0;    
				p1 <= w[127]*din_1; 
				p2 <= w[143]*din_2; 
				p3 <= w[159]*din_3; 
				p4 <= w[175]*din_4; 
				p5 <= w[191]*din_5;            
			end
	default:begin
				p0 <= 0;    
				p1 <= 0; 
				p2 <= 0; 
				p3 <= 0; 
				p4 <= 0; 
				p5 <= 0;
			end
	endcase
	end
	*/
	// 输入与权重相乘
	always@(posedge clk)
	begin
	case(cnt)
	4'd0:begin
		if(!state)
			begin
				p0 <= w[0] *din_0;    
				p1 <= w[16]*din_1; 
				p2 <= w[32]*din_2;
				p3 <= w[48]*din_3; 
				p4 <= w[64]*din_4; 
				p5 <= w[80]*din_5;
			end
		else
			begin
				p0 <= w[96]*din_0;    
				p1 <= w[112]*din_1; 
				p2 <= w[128]*din_2; 
				p3 <= w[144]*din_3; 
				p4 <= w[160]*din_4; 
				p5 <= w[176]*din_5;    
			end
		end
	4'd1:begin
		if(!state)
			begin
				p0 <= w[1]*din_0;    
				p1 <= w[17]*din_1; 
				p2 <= w[33]*din_2; 
				p3 <= w[49]*din_3; 
				p4 <= w[65]*din_4; 
				p5 <= w[81]*din_5;
			end
		else
			begin
				p0 <= w[97]*din_0;    
				p1 <= w[113]*din_1; 
				p2 <= w[129]*din_2; 
				p3 <= w[145]*din_3; 
				p4 <= w[161]*din_4; 
				p5 <= w[177]*din_5;
			end
		end
	4'd2:begin
		if(!state)
			begin
				p0 <= w[2]*din_0;    
				p1 <= w[18]*din_1;
				p2 <= w[34]*din_2; 
				p3 <= w[50]*din_3; 
				p4 <= w[66]*din_4;
				p5 <= w[82]*din_5;
			end
		else
			begin
				p0 <= w[98]*din_0;    
				p1 <= w[114]*din_1; 
				p2 <= w[130]*din_2; 
				p3 <= w[146]*din_3; 
				p4 <= w[162]*din_4; 
				p5 <= w[178]*din_5;            
			end
		end
	4'd3:begin
		if(!state)
			begin
				p0 <= w[3]*din_0;    
				p1 <= w[19]*din_1;
				p2 <= w[35]*din_2; 
				p3 <= w[51]*din_3; 
				p4 <= w[67]*din_4;
				p5 <= w[83]*din_5;
			end
		else
			begin
				p0 <= w[99]*din_0;    
				p1 <= w[115]*din_1; 
				p2 <= w[131]*din_2; 
				p3 <= w[147]*din_3; 
				p4 <= w[163]*din_4; 
				p5 <= w[179]*din_5;            
			end
		end
	4'd4:begin
		if(!state)
			begin
				p0 <= w[4]*din_0;    
				p1 <= w[20]*din_1;
				p2 <= w[36]*din_2; 
				p3 <= w[52]*din_3; 
				p4 <= w[68]*din_4;
				p5 <= w[84]*din_5;
			end
		else
			begin
				p0 <= w[100]*din_0;    
				p1 <= w[116]*din_1; 
				p2 <= w[132]*din_2; 
				p3 <= w[148]*din_3; 
				p4 <= w[164]*din_4; 
				p5 <= w[180]*din_5;            
			end
		end
	4'd5:begin
		if(!state)
			begin
				p0 <= w[5]*din_0;    
				p1 <= w[21]*din_1;
				p2 <= w[37]*din_2; 
				p3 <= w[53]*din_3; 
				p4 <= w[69]*din_4;
				p5 <= w[85]*din_5;
			end
		else
			begin
				p0 <= w[101]*din_0;    
				p1 <= w[117]*din_1; 
				p2 <= w[133]*din_2; 
				p3 <= w[149]*din_3; 
				p4 <= w[165]*din_4; 
				p5 <= w[181]*din_5;            
			end
		end
	4'd6:begin
		if(!state)
			begin
				p0 <= w[6]*din_0;    
				p1 <= w[22]*din_1;
				p2 <= w[38]*din_2; 
				p3 <= w[54]*din_3; 
				p4 <= w[70]*din_4;
				p5 <= w[86]*din_5;
			end
		else
			begin
				p0 <= w[102]*din_0;    
				p1 <= w[118]*din_1; 
				p2 <= w[134]*din_2; 
				p3 <= w[150]*din_3; 
				p4 <= w[166]*din_4; 
				p5 <= w[182]*din_5;            
			end
		end
	4'd7:begin
		if(!state)
			begin
				p0 <= w[7]*din_0;    
				p1 <= w[23]*din_1;
				p2 <= w[39]*din_2; 
				p3 <= w[55]*din_3; 
				p4 <= w[71]*din_4;
				p5 <= w[87]*din_5;
			end
		else
			begin
				p0 <= w[103]*din_0;    
				p1 <= w[119]*din_1; 
				p2 <= w[135]*din_2; 
				p3 <= w[151]*din_3; 
				p4 <= w[167]*din_4; 
				p5 <= w[183]*din_5;            
			end
		end
	4'd8:begin
		if(!state)
			begin
				p0 <= w[8]*din_0;    
				p1 <= w[24]*din_1;
				p2 <= w[40]*din_2; 
				p3 <= w[56]*din_3; 
				p4 <= w[72]*din_4;
				p5 <= w[88]*din_5;
			end
		else
			begin
				p0 <= w[104]*din_0;    
				p1 <= w[120]*din_1; 
				p2 <= w[136]*din_2; 
				p3 <= w[152]*din_3; 
				p4 <= w[168]*din_4; 
				p5 <= w[184]*din_5;            
			end
		end
	4'd9:begin
		if(!state)
			begin
				p0 <= w[9]*din_0;    
				p1 <= w[25]*din_1;
				p2 <= w[41]*din_2; 
				p3 <= w[57]*din_3; 
				p4 <= w[73]*din_4;
				p5 <= w[89]*din_5;
			end
		else
			begin
				p0 <= w[105]*din_0;    
				p1 <= w[121]*din_1; 
				p2 <= w[137]*din_2; 
				p3 <= w[153]*din_3; 
				p4 <= w[169]*din_4; 
				p5 <= w[185]*din_5;            
			end
		end
	4'd10:begin
		if(!state)
			begin
				p0 <= w[10]*din_0;    
				p1 <= w[26]*din_1;
				p2 <= w[42]*din_2; 
				p3 <= w[58]*din_3; 
				p4 <= w[74]*din_4;
				p5 <= w[90]*din_5;
			end
		else
			begin
				p0 <= w[106]*din_0;    
				p1 <= w[122]*din_1; 
				p2 <= w[138]*din_2; 
				p3 <= w[154]*din_3; 
				p4 <= w[170]*din_4; 
				p5 <= w[186]*din_5;            
			end
		end
	4'd11:begin
		if(!state)
			begin
				p0 <= w[11]*din_0;    
				p1 <= w[27]*din_1;
				p2 <= w[43]*din_2; 
				p3 <= w[59]*din_3; 
				p4 <= w[75]*din_4;
				p5 <= w[91]*din_5;
			end
		else
			begin
				p0 <= w[107]*din_0;    
				p1 <= w[123]*din_1; 
				p2 <= w[139]*din_2; 
				p3 <= w[155]*din_3; 
				p4 <= w[171]*din_4; 
				p5 <= w[187]*din_5;            
			end
		end
	4'd12:begin
		if(!state)
			begin
				p0 <= w[12]*din_0;    
				p1 <= w[28]*din_1;
				p2 <= w[44]*din_2; 
				p3 <= w[60]*din_3; 
				p4 <= w[76]*din_4;
				p5 <= w[92]*din_5;
			end
		else
			begin
				p0 <= w[108]*din_0;    
				p1 <= w[124]*din_1; 
				p2 <= w[140]*din_2; 
				p3 <= w[156]*din_3; 
				p4 <= w[172]*din_4; 
				p5 <= w[188]*din_5;            
			end
		end
	4'd13:begin
		if(!state)
			begin
				p0 <= w[13]*din_0;    
				p1 <= w[29]*din_1;
				p2 <= w[45]*din_2; 
				p3 <= w[61]*din_3; 
				p4 <= w[77]*din_4;
				p5 <= w[93]*din_5;
			end
		else
			begin
				p0 <= w[109]*din_0;    
				p1 <= w[125]*din_1; 
				p2 <= w[141]*din_2; 
				p3 <= w[157]*din_3; 
				p4 <= w[173]*din_4; 
				p5 <= w[189]*din_5;            
			end
		end
	4'd14:begin
		if(!state)
			begin
				p0 <= w[14]*din_0;    
				p1 <= w[30]*din_1;
				p2 <= w[46]*din_2; 
				p3 <= w[62]*din_3; 
				p4 <= w[78]*din_4;
				p5 <= w[94]*din_5;
			end
		else
			begin
				p0 <= w[110]*din_0;    
				p1 <= w[126]*din_1; 
				p2 <= w[142]*din_2; 
				p3 <= w[158]*din_3; 
				p4 <= w[174]*din_4; 
				p5 <= w[190]*din_5;            
			end
		end
	4'd15:begin
		if(!state)
			begin
				p0 <= w[15]*din_0;    
				p1 <= w[31]*din_1;
				p2 <= w[47]*din_2; 
				p3 <= w[63]*din_3; 
				p4 <= w[79]*din_4;
				p5 <= w[95]*din_5;
			end
		else
			begin
				p0 <= w[111]*din_0;    
				p1 <= w[127]*din_1; 
				p2 <= w[143]*din_2; 
				p3 <= w[159]*din_3; 
				p4 <= w[175]*din_4; 
				p5 <= w[191]*din_5;            
			end
		end
	default:begin
				p0 <= 0;    
				p1 <= 0; 
				p2 <= 0; 
				p3 <= 0; 
				p4 <= 0; 
				p5 <= 0;
			end
	endcase
	end

	// 
	always@(posedge clk)
	begin
		sum00 <= p0 + p1;    
		sum01 <= p2 + p3;
		sum02 <= p4 + p5;
	end
	
	always@(posedge clk)
	begin
		sum10 <= sum00 + sum01;
		sum11 <= sum02;
	end
	
	always@(posedge clk)
		sum <= sum10 + sum11;  // 每次并行度为6的输入与权重相乘计算结果
		
	assign dout = dout_r;
	assign ovalid = wren;
	
endmodule
