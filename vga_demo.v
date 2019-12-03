`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw2, Sw1,Sw0, btnU,btnL,btnR, btnD,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	input ClkPort, btnU, btnL, btnR, btnD, Sw0, Sw1, Sw2;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg vga_r; 
	reg vga_g, vga_b;
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ACK, ClkPort, board_clk, clk,t,  button_clk;
	
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	BUF BUF4 (ACK, Sw2);
	
	reg [1:0] state;
	localparam 
	INI = 2'b00,
	GAME_ON = 2'b01,
	GAME_OVER = 2'b10,
	GJ = 2'b11;
	
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11

	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;
	
	
	//parameter W = 8'b111_111_11;
	
	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] position, position1;
	reg tch, tch1, tch2, tch3;
	wire up, right, left, down, up1, right1, left1, down1, up2, right2, left2, down2, up3, right3, left3, down3;
	assign up = position < 66;
	assign right = position1 > 54;
	assign left = position1 < 66;
	assign down = position >54;
	
	assign up1 = position < 460;
	assign right1 = position1 > 54;
	assign left1 = position1 < 66;
	assign down1 = position >448;
	
	assign up2 = position < 66;
	assign right2 = position1 > 558;
	assign left2 = position1 < 570;
	assign down2 = position > 54;
	
	assign up3 = position < 460;
	assign right3 = position1 > 558;
	assign left3 = position1 < 570;
	assign down3 = position > 448;
	
	wire flag = (CounterY >= 56 && CounterY <= 64 && CounterX >= 56 && CounterX <= 64);
	wire flag1 = (CounterY >= 450 && CounterY <= 458 && CounterX >= 56 && CounterX <= 64);
	wire flag2 = (CounterY >= 56 && CounterY <= 64 && CounterX >= 560 && CounterX <= 568);
	wire flag3 = (CounterY >= 450 && CounterY <= 458 && CounterX >= 560 && CounterX <= 568);
	
	wire [9:0] boudL, boudT, boudR, boudB;
	assign boudT = CounterY >= 50 && CounterY <= 100 && CounterX >= 50 && CounterX <= 570;
	assign boudB = CounterY >= 420 && CounterY <= 470 && CounterX >= 50 && CounterX <= 570;
	assign boudL = CounterX >= 50 && CounterX <= 100 && CounterY >= 50 && CounterY <= 470;
	assign boudR = CounterX >= 520 && CounterX <=570 && CounterY >= 50 && CounterY <= 470;
	
	wire trap = (CounterY >= 50 && CounterY <= 70 && CounterX >= 200 && CounterX <= 260);
	wire trap1 = (CounterY >= 380 && CounterY <= 400 && CounterX >= 555 && CounterX <= 570);
	wire trap2 = (CounterY >= 445 && CounterY <= 470 && CounterX >= 350 && CounterX <= 370);
	wire trap3 = (CounterY >= 110 && CounterY <= 200 && CounterX >= 50 && CounterX <= 75);
	
	
	always @(posedge reset, posedge DIV_CLK[21])
		begin
			if(reset)
				begin
					state <= INI;
				end
			else
				case(state)
				INI:begin
					position<=70;
					position1<=320;
					tch <= 0;
					tch1 <= 0;
					tch2 <= 0;
					tch3 <= 0;
					SSD3 <= 4'b0000;
					SSD2 <= 4'b0000;
					SSD1 <= 4'b0000;
					SSD0 <= 4'b0000;
					if(start)
						state <= GAME_ON;
				end
			
				GAME_ON:begin
						//trap
						if(position < 80 && ((position1 >= 260 && position1 < 274 && btnL) || (position1 <= 200 && position1 > 186 && btnR))) 
							state <= GAME_OVER;
						if(position1 > 190 && position1 < 270 && position < 84 && btnU)
							state <= GAME_OVER;
						
						//trap1
						if(position1 > 545 && ((position <= 380 && position > 366 && btnD )|| (position >= 400 && position < 414 && btnU)))  
							state <= GAME_OVER;
						if(position > 370 && position < 410 && position1 > 541 && btnR)
							state <= GAME_OVER;
						
						//trap2
						if(position > 435 && ((position1 <= 350 && position1 > 336 && btnR)||(position1 >=370 && position1 < 384 && btnL)))
							state <= GAME_OVER;
						if(position1 > 340 && position1 < 380 && position > 431 && btnD)
							state <= GAME_OVER;
						
						//trap3
						if(position1 < 85 && ((position >= 200 && position < 214 && btnU) || (position <= 110 && position > 96 && btnD)))
							state <= GAME_OVER;
						if(position > 100 && position < 210 && position1 < 89 && btnL)
							state <= GAME_OVER;
							
						
						if(btnD && ~btnU)
						begin
							if((position1 >= 526 || position1 <= 94) && position < 460 )
								position <= position + 4;
							else if((position < 460 && position > 426) || (position < 90 && position > 56))
									position <= position + 4;
								else 
									position <= position - 2;
							//end
						end
						else if(btnU && ~btnD)
						begin
							if((position1 >= 526 || position1 <= 94) && position > 60 )
								position <= position - 4;
							else if((position < 464 && position > 430) || (position < 94 && position > 60))
									position <= position - 4;
								else
									position <= position + 2;
							//end
						end
						if(btnL && ~btnR)
						begin
							if ((position >= 426 || position <= 94) && position1 > 60 )
								position1 <= position1 - 4;
							else if ((position1 < 564 && position1 > 530) || (position1 < 94 && position1 > 60))
								position1 <= position1 - 4;
							else
								position1 <= position1 + 2;
						end
						else if(btnR && ~ btnL)
						begin
								if ((position >= 426 || position <= 94) && position1 < 560)
									position1 <= position1 + 4;
								else if ((position1 < 560 && position1 > 526) || (position1 < 90 && position1 > 56))
									position1 <= position1 + 4;	
								else
									position1 <= position1 - 2;
						end
						
						
						
						
						if(up && down && right && left)
							tch <= 1;
						if(up1 && down1 && right1 && left1)
							tch1 <= 1;
						if(up2 && down2 && right2 && left2)
							tch2 <= 1;
						if(up3 && down3 && right3 && left3)
							tch3 <= 1;
						
						if(tch && tch1 && tch2 && tch3)
							state <= GJ;
				end
				GAME_OVER:
				begin
					SSD3 <= 4'b0111;
					SSD2 <= 4'b0000;
					SSD1 <= 4'b0101;
					SSD0 <= 4'b1110;
					if(ACK)
						state <= INI;
				end
				GJ:
				begin
					SSD3 <= 4'b0011;
					SSD2 <= 4'b0010;
					SSD1 <= 4'b1100;
					SSD0 <= 4'b1101;
					
					if(ACK)
						state <= INI;
				end
				
				
				endcase
		end
		
	
	
	
	wire R = (CounterY>=(position - 10) && CounterY <=(position + 10))&& (CounterX>=(position1 - 10) && CounterX <= (position1 + 10)) || ~(boudR || boudT || boudB || boudL);
	wire G = ~(boudR || boudT || boudB || boudL) || trap || trap1 || trap2 || trap3;//CounterX>25 && CounterX<590 && CounterY[5:3]==7; 
	wire B =  (flag1 && ~tch1) || (flag2 && ~tch2) || (flag3 && ~tch3) || (flag && ~tch) || ~(boudR || boudT || boudB || boudL);// (CounterX[5:3] ==6) && (CounterY[5:3] ==6)  && ~(CounterX[9:6]==0 && CounterY[9:6]==0 && flag);
		

		
	
	always @(posedge clk)
	begin
		vga_r <= R & inDisplayArea;
		vga_g <= G & inDisplayArea;
		vga_b <= B & inDisplayArea;
	
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	reg 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	//assign SSD3 = 4'b1111;
	//assign SSD2 = 4'b1111;
	//assign SSD1 = 4'b1111;
	//assign SSD0 = position[3:0];
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			//4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3 //W
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5 //S
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			//4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1011: SSD_CATHODES = 7'b0001000 ; //10 or A
			4'b1011: SSD_CATHODES = 7'b1100000; // B
			4'b1100: SSD_CATHODES = 7'b0110001; // C // N
			//4'b1101: SSD_CATHODES = 7'b1000010; // D
			4'b1110: SSD_CATHODES = 7'b0110000; // E
			4'b1111: SSD_CATHODES = 7'b0111000; // F 
			
			4'b0111: SSD_CATHODES = 7'b1110001; // L
			4'b0010: SSD_CATHODES = 7'b1111110; // I
			4'b1101: SSD_CATHODES = 7'b1111111; // empty
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule
