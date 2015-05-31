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
    input rst,
    input btnM,
    input btnR,
    input btnL,
    input validStart,
    input [1:0] prevState,
    input newGame,
	 
    output reg [1:0] state
    
    );
    
    
    always @ (posedge clk)
    if (rst || newGame)
    begin
        state <= 2'b00;
    end
    else
        begin
            case(prevState)
                    2'b00: // menu
                        begin
                            if (btnM == 1 && validStart == 1)
                                state <= 2'b01; // game start
                            else if (btnR == 1)
                                state <= 2'b10; // high score
                            else
                                state <= prevState;
                            // scrolling logic handled in gameplay.v under welcome
                        end
                    2'b01: // game start
                        begin
                           // game logic
                           state <= prevState;
                           // game logic handled in gameplay.v
                        end
                    2'b10: // highScore
                        begin
                            // display high score
                            if (btnL == 1)
                                state <= 2'b00; // menu
                            else
                                state <= prevState;
                            // High score logic handled in high score
                        end
                    default: 
                            begin
                                state <= 2'b00; // menu
                            end
            endcase
            
    end
    

endmodule
