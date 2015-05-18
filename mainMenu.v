`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:58:39 05/13/2015 
// Design Name: 
// Module Name:    mainMenu 
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
module mainMenu(
    //input
    input clk,
    input btnM,
    input btnR,
    input validStart,
    
    output reg menu,
    output reg highScore,
    output reg gameStart
    
    );
    
    always @ (posedge clk)
    begin
        if (btnM == 1 && validStart == 1)
            gameStart <= 1;
        else
            gameStart <= 0;
    end
    

endmodule
