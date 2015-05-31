`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:39:18 04/29/2015 
// Design Name: 
// Module Name:    masterCLK 
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


module masterCLK(
    input clk, 
    input rst,
    
    output reg clock0,      // .71 Hz
    output reg clock1,      // .833 Hz
    output reg clock2,      // 1 Hz
    output reg clock3,      // 1.25 Hz
    output reg clock4,      // 1.66 Hz
    output reg clock5,      // 2.5 Hz
    output reg clock6,      // 5Hz
    
    output reg clockScroll, // 2 Hz
    output reg clockFast,   // 500 Hz
    output reg clockBlink,  //   3 Hz
    output reg clockInit    // 50 Hz
	 
    );

     reg [26:0] counter0;
     reg [26:0] counter1;
     reg [26:0] counter2;
     reg [26:0] counter3;
     reg [26:0] counter4;
     reg [26:0] counter5;
     reg [26:0] counter6;
     
     reg [26:0] counterScroll;
     reg [26:0] counterBlink;
	  reg [26:0] fastCounter;
     reg [26:0] counterInit;
	 
	 
    // 100 Mhz = 100 000 000, 27 bits needed
    // 100 000 000 Hz
    
    always @ (posedge clk) 
    begin
        if (rst)
            begin
                clock0 <= 0;      // .71 Hz
                clock1 <= 0;      // .833 Hz
                clock2 <= 0;      // 1 Hz
                clock3 <= 0;      // 1.25 Hz
                clock4 <= 0;      // 1.66 Hz
                clock5 <= 0;      // 2.5 Hz
                clock6 <= 0;      // 5 Hz
                
                clockScroll <= 0; // 2 Hz
                clockFast <= 0;   // 500 Hz
                clockBlink <= 0;  // 3 Hz
                clockInit <= 0;
					 
                counter0 <= 'd0;
                counter1 <= 'd0;
                counter2 <= 'd0;
                counter3 <= 'd0;
                counter4 <= 'd0;
                counter5 <= 'd0;
                counter6 <= 'd0;
                
                counterScroll <= 'd0;
                counterBlink <= 'd0;
				    fastCounter <= 'd0;
                counterInit <= 'd0;
					 
            end
        else
            begin
                if (counter0 == 'd1408450/*70*/) // .71 Hz
                begin
                    clock0 <= ~clock0;
                    counter0 <= 'd0;
                end
                else
					counter0 <= counter0 + 'd1;
                
                if (counter1 == 'd1200480/*19*/) // .833 Hz
                begin
                    clock1 <= ~clock1;
                    counter1 <= 'd0;
                end
                else
					counter1 <= counter1 + 'd1; 
                    
                if (counter2 == 'd1000000/*00*/) // 1Hz
                begin
                    clock2 <= ~clock2;
                    counter2 <= 'd0;
                end
                else
                    counter2 <= counter2 + 'd1;
                    
                if (counter3 == 'd800000/*00*/) // 1.25 Hz
                begin
                    clock3 <= ~clock3;
                    counter3 <= 'd0;
                end
                else
                    counter3 <= counter3 + 'd1;
                
                if (counter4 == 'd602409/*63*/) // 1.66 Hz
                begin
                    clock4 <= ~clock4;
                    counter4 <= 'd0;
                end
                else
                    counter4 <= counter4 + 'd1;
                
                if (counter5 == 'd400000/*00*/) // 2.5 Hz
                begin
                    clock5 <= ~clock5;
                    counter5 <= 'd0;
                end
                else
                    counter5 <= counter5 + 'd1;
                
                if (counter6 == 'd200000/*00*/) // 5 Hz
                begin
                    clock6 <= ~clock6;
                    counter6 <= 'd0;
                end
                else
                    counter6 <= counter6 + 'd1;
           
                
                if (counterScroll == 'd500000/*00*/)
                begin
                    clockScroll <= ~clockScroll;
				    counterScroll <= 'd0;
                end
                else
					counterScroll <= counterScroll + 'd1;  
                    
                if (fastCounter == 'd2000/*00*/)
                begin
                    clockFast <= ~clockFast;
				    fastCounter <= 'd0;
                end
                else
					fastCounter <= fastCounter + 'd1;

                // If we say 1 second per 100 MHz, this is .33 seconds for 3 ticks a sec
                if (counterBlink == 'd333333/*33*/) 
                begin
                    clockBlink <= ~clockBlink;
                    counterBlink <= 'd0;
                end
                else
                    counterBlink <= counterBlink + 'd1;
                
                if (counterInit == 'd2000000)
                begin
                    clockInit <= ~clockInit;
				    counterInit <= 'd0;
                end
                else
					counterInit <= counterInit + 'd1;

            end     // end else block
    end             // end always block 

  
endmodule
