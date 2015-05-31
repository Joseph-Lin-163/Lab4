`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:03:38 05/06/2015 
// Design Name: 
// Module Name:    master 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module master(
    input clk,
    input rst,
	 input btnM, input btnL, input btnR, input btnU, input btnD,
	 input [7:0] sw,
	 output [6:0] led,
    output [6:0] out,
    output [3:0] an
    );
    
	 // remember reg for input and wire for output
    
	 reg [1:0] random = 'b00;
	 

    wire clock0;      // .71 Hz
    wire clock1;      // .833 Hz
    wire clock2;      // 1 Hz
    wire clock3;      // 1.25 Hz
    wire clock4;      // 1.66 Hz
    wire clock5;      // 2.5 Hz
    wire clock6;      // 5Hz
    
    
    wire clockScroll;
    wire clockFast;
    wire clockBlink;
    wire clockInit;
    wire validStart;
	 
	 wire [1:0] state;
	 
	 wire clkOut;
    wire newGame;

	 
   wire [17:0] clk_dv_inc;

   reg [16:0]  clk_dv;
   reg         clk_en;
   reg         clk_en_d;
      
   reg [7:0]   inst_wd;
   reg         inst_vldR;
	reg         inst_vldM;
	reg         inst_vldL;
	reg         inst_vldU;
	reg         inst_vldD;
   reg [2:0]   step_dR;
	reg [2:0]   step_dM;
	reg [2:0]   step_dL;
	reg [2:0]   step_dU;
	reg [2:0]   step_dD;
	reg rOut = 0;
	reg mOut = 0;
	reg lOut = 0;
	reg uOut = 0;
	reg dOut = 0;
	
	

   // ===========================================================================
   // 763Hz timing signal for clock enable
   // ===========================================================================

   assign clk_dv_inc = clk_dv + 1;
   
   always @ (posedge clk)
     if (rst)
       begin
          clk_dv   <= 0;
          clk_en   <= 1'b0;
          clk_en_d <= 1'b0;
       end
     else
       begin
          clk_dv   <= clk_dv_inc[16:0];
          clk_en   <= clk_dv_inc[17];
          clk_en_d <= clk_en;
       end
   
   // ===========================================================================
   // Instruction Stepping Control
   // ===========================================================================

   always @ (posedge clk)
     if (rst)
       begin
          //inst_wd[7:0] <= 0;
          step_dR[2:0]  <= 0;
			 step_dM[2:0]  <= 0;
			 step_dL[2:0]  <= 0;
			 step_dU[2:0]  <= 0;
			 step_dD[2:0]  <= 0;
       end
     else if (clk_en)
       begin
          //inst_wd[7:0] <= sw[7:0]; // give the next instruction
          step_dR[2:0]  <= {btnR, step_dR[2:1]};
			 step_dM[2:0]  <= {btnR, step_dM[2:1]};
			 step_dL[2:0]  <= {btnR, step_dL[2:1]};
			 step_dU[2:0]  <= {btnR, step_dU[2:1]};
			 step_dD[2:0]  <= {btnR, step_dD[2:1]};
       end

   always @ (posedge clk)
     if (rst)
	  begin
       inst_vldR <= 1'b0;
		 inst_vldM <= 1'b0;
		 inst_vldL <= 1'b0;
		 inst_vldU <= 1'b0;
		 inst_vldD <= 1'b0;
	  end
     else
	  begin
       inst_vldR <= ~step_dR[0] & step_dR[1] & clk_en_d;
		 inst_vldM <= ~step_dM[0] & step_dM[1] & clk_en_d;
		 inst_vldL <= ~step_dL[0] & step_dL[1] & clk_en_d;
		 inst_vldU <= ~step_dU[0] & step_dU[1] & clk_en_d;
		 inst_vldD <= ~step_dD[0] & step_dD[1] & clk_en_d;
	  end
       
   always @ (posedge clk)
    begin
        if (inst_vldR)
				rOut <= 1;
		  else
				rOut <= 0;
		  if (inst_vldM)
				mOut <= 1;
		  else
				mOut <= 0;
		  if (inst_vldL)
				lOut <= 1;
		  else
				lOut <= 0;
		  if (inst_vldU)
				uOut <= 1;
		  else
				uOut <= 0;
		  if (inst_vldD)
				dOut <= 1;
		  else
				dOut <= 0;
    end   
       
	 always @ (posedge clk)
	 begin
		if (btnR || btnL || btnM || btnU || btnD)
			random <= random + 1;
	 end
		 
    assign led = sw;
	 
    masterCLK myCLK (
	      // inputs
          .clk (clk),
		    .rst (rst),
		  
		  //outputs
          .clock0 (clock0),      // .71 Hz
          .clock1 (clock1),      // .833 Hz
          .clock2 (clock2),      // 1 Hz
          .clock3 (clock3),      // 1.25 Hz
          .clock4 (clock4),      // 1.66 Hz
          .clock5 (clock5),      // 2.5 Hz
          .clock6 (clock6),      // 5Hz
    
          .clockScroll(clockScroll), // 2Hz
          .clockFast(clockFast),     // 500 Hz
          .clockBlink(clockBlink),   //   3 Hz
          .clockInit(clockInit)      // 50 Hz
        );
 
 
    levels theLevels(
        //inputs
        .clk(clk), 
        //input rst,
        .sw (sw),
    
        .clock0(clock0),      // .71 Hz
        .clock1(clock1),      // .833 Hz
        .clock2(clock2),      // 1 Hz
        .clock3(clock3),      // 1.25 Hz
        .clock4(clock4),      // 1.66 Hz
        .clock5(clock5),      // 2.5 Hz
        .clock6(clock6),      // 5Hz
        // output
        .validStart(validStart),
        .clkOut(clkOut)
    );
    
    mainMenu mm(
        //input
        .clk (clk),
        .rst (rst),
        .btnM (mOut),
        .btnR(rOut),
        .btnL(lOut),
        .validStart(validStart),
        .prevState (state),
		  .newGame(newGame),
        // output
        .state(state)
    
    );
	 /*
    welcome w(
        // input
        .clockFast(clockFast),
        .clockScroll(clockScroll),
		  .state(state),
        // output
        .an (an),
        .out (out)
    );*/
        
	gameplay gp(
	 // input
    .clk(clkOut),
	 .clockScroll(clockScroll),
	 .clk1Hz(clock2),
    .clkInit(clockInit),
    .state(state),
	 .random(random),
    
	 .btnR(rOut),
	 .btnM(mOut),
	 .btnL(lOut),
	 .btnU(uOut),
	 .btnD(dOut),
	 .hint(sw[7]),
	 
	 .clockFast(clockFast),
	 // output
    .an(an),
    .out(out),
	 .newGame(newGame)
    );		
 
			

endmodule
