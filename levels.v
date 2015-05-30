`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:43:10 05/13/2015 
// Design Name: 
// Module Name:    levels 
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
module levels(
    //inputs
    input clk, 
    //input rst,
    input [7:0] sw,
    
    input clock0,      // .71 Hz
    input clock1,      // .833 Hz
    input clock2,      // 1 Hz
    input clock3,      // 1.25 Hz
    input clock4,      // 1.66 Hz
    input clock5,      // 2.5 Hz
    input clock6,      // 5Hz
    
    output reg validStart,
    output reg clkOut
    );
    
    always @ (posedge clk)
    begin
                case(sw)
                    8'b00000001: 
                            begin
                                clkOut <= clock0;
                                validStart <= 1;
                            end
                    8'b00000011: 
                            begin
                                clkOut <= clock1;
                                validStart <= 1;
                            end
                    8'b00000111: 
                            begin
                                clkOut <= clock2;
                                validStart <= 1;
                            end
                    8'b00001111: 
                            begin
                                clkOut <= clock3;
                                validStart <= 1;
                            end
                    8'b00011111: 
                            begin
                                clkOut <= clock4;
                                validStart <= 1;
                            end
                    8'b00111111: 
                            begin
                                clkOut <= clock5;
                                validStart <= 1;
                            end
                    8'b01111111:
                            begin
                                clkOut <= clock6;
                                validStart <= 1;
                            end
                    default: 
                            begin
                                clkOut <= clock0;
                                validStart <= 0;
                            end
                endcase
    end


endmodule
