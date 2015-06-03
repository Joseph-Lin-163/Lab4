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
    reg btnM, btnL, btnR, btnU, btnD;
    reg [7:0] sw;
    wire [3:0] an;
    wire [6:0] out;
	 reg [1:0] random;
	 
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
	 wire gameOver;
    
    
    wire [1:0] state;
	 
	 wire clkOut;
    wire newGameFlag;
	 
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
        .btnM (btnM),
        .btnR(btnR),
        .btnL(btnL),
        .validStart(validStart),
        .prevState (state),
		  .newGameFlag(newGameFlag),
		  .gameOver(gameOver),
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
    );
    */
	gameplay gp(
	 // input
    .clk(clkOut),
	 .clockScroll(clockScroll),
	 .clk1Hz(clock2),
    .clkInit(clockInit),
    .state(state),
	 .random(random),
    
	 .btnR(btnR),
	 .btnM(btnM),
	 .btnL(btnL),
	 .btnU(btnU),
	 .btnD(btnD),
	 .hint(sw[7]),
	 
	 .clockFast(clockFast),
	 // output
    .an(an),
    .out(out),
	 .newGameFlag(newGameFlag),
	 .gameOverOut(gameOver)
    );		
            
    initial begin
        clk = 1'b0;
		rst = 1'b1;
        repeat(4) #10 clk = ~clk;
		rst = 1'b0;
        forever #1 clk = ~clk;
    end
    
    initial begin
          btnR = 0;
          btnM = 0;
          btnL = 0;
			 btnU = 0;
			 btnD = 0;
          sw = 'b01111111;
          if (sw == 'b01111111)
				random = 'b00;
			 else
				random = 'b10;
          #50000
		    rst = 1'b1;
          #50000
          rst = 0;
          #500000
          btnR = 1;
          #50000
          btnR = 0;
          #100000
          btnL = 1;
          #50000
          btnL = 0;
			  
          #50000000
			 btnM = 1;
			 #500000
			 btnM = 0;
			 #300000000
			 #100000000 // 100 ms
			 #20000000
			 // Pattern 'b00
			 btnL = 1;
			 #10000000
			 btnL = 0;
			 #20000000
			 btnU = 1;
			 #10000000
			 btnU = 0;
			 #20000000
			 btnD = 1;
			 #10000000
			 btnD = 0;
			 #20000000
			 btnD = 1;
			 #10000000
			 btnD = 0;
			 #20000000
			 btnM = 1;
			 #10000000
			 btnM = 0;
			 #50000000
			 btnR = 1;
			 #50000000
			 btnL = 1;
			 #20000000
			 btnM = 1;
			 #20000000
			 btnM = 0;
          #500000000
          #500000000
          #500000000
		    
    $finish;
    end
endmodule
