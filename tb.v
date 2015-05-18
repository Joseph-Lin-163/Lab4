`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:56:18 04/29/2015 
// Design Name: 
// Module Name:    tb 
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
module tb(
    );
	// remember reg for input and wire for output
    reg clk, rst;
	 
    wire clock0;      // .71 Hz
    wire clock1;      // .833 Hz
    wire clock2;      // 1 Hz
    wire clock3;      // 1.25 Hz
    wire clock4;      // 1.66 Hz
    wire clock5;      // 2.5 Hz
    wire clock6;      // 5Hz
    wire clockFast;
    wire clockBlink;
	 
	 reg ADJ, SEL, PAUSE;
	 wire clkOut;
     
	 wire [6:0] out;
    wire [3:0] an;
	 
    
    masterCLK myCLK (
	     // inputs
        .clk (clk),
		.rst (rst),
		  
		  //outputs
        .clock0 (clock0),
        .clock1 (clock1),
        .clock2 (clock2),
        .clock3 (clock3),
        .clock4 (clock4),
        .clock5 (clock5),
        .clock6 (clock6),
        .clockFast (clockFast),
        .clockBlink (clockBlink)
        );
        
	/* masterToTimer mtt (
			// inputs
			.ADJ (ADJ),
			.SEL (SEL),
         
			.clk (clk),
			.clock2Hz (clock2Hz),
			.clock1Hz (clock1Hz),

			//output
			.clkOut (clkOut)
			);
			 
	 timer timer_t (
		// input
		.masterCLK(clk),
		.SEL(SEL),
		.ADJ(ADJ),
		.rst(rst),
		.clk(clkOut),
		.PAUSE(PAUSE),
      .clockFast(clockFast),
		.clockBlink(clockBlink),
        
		//output
      .an (an),
		.out (out)	
		);*/
			
			
    initial begin
        clk = 1'b0;
		  rst = 1'b1;
        repeat(4) #10 clk = ~clk;
		  rst = 1'b0;
        forever #1 clk = ~clk;
    end
    
    initial begin
			ADJ = 0;
			PAUSE = 0;
			SEL = 0;
		  
        #5000000
		  rst = 1'b1;
		  #5000000
		  rst = 1'b0;
		  #50000000
		  rst = 1'b1;
		  #5000000
		  rst = 1'b0;
		  #50000000
		  PAUSE = 1'b1;
		  #5000000
		  PAUSE = 1'b0;
		  ADJ = 1'b1;
		  #500000000
		  SEL = 1;
		  #500000000
		  ADJ = 0;
		  #500000000
		   ADJ = 0;
        #100000000
    $finish;
    end
endmodule
