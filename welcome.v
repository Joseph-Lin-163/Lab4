`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:44:38 05/18/2015 
// Design Name: 
// Module Name:    welcome 
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
module welcome(
    input clockFast,
    input clockScroll,
    output reg [3:0] an,
    output reg [6:0] out
    );
    
    
    /*
    Welcome Message:
W: 1010101
E: 0000110
L: 1000111
C: 1000110
O: 1000000
M: 1101010
E: 0000110
S: 1111111 (Space)
T: 0000111
O: 1000000
S: 1111111 (Space)
S: 0010010
I: 1001111
M: 1101010
O: 1000000
N: 1001000
S: 1111111 (Space)
S: 0010010
A: 0100000
Y: 0010001
S: 0010010
S: 1111111 (Space)
S: 1111111 (Space)
S: 1111111 (Space)
S: 1111111 (Space)
S: 1111111 (Space)

*/
    
    reg [6:0] r = 'b1010101;
    reg [6:0] mr = 'b1111111;
    reg [6:0] ml = 'b1111111;
    reg [6:0] l = 'b1111111;
    
    reg [1:0] cnt = 0;
    reg [4:0] inner = 0;
    
    
    always @(posedge clockScroll)
    begin
                    case(inner)
                        'b00000: r <= 1010101;
                        'b00001: r <= 0000110;
                        'b00010: r <= 1000111;
                        'b00011: r <= 1000110;
                        'b00100: r <= 1000000;
                        'b00101: r <= 1101010;
                        'b00110: r <= 0000110;
                        'b00111: r <= 1111111; //(Space)
                        'b01000: r <= 0000111;
                        'b01001: r <= 1000000;
                        'b01010: r <= 1111111; //(Space)
                        'b01011: r <= 0010010;
                        'b01100: r <= 1001111;
                        'b01101: r <= 1101010;
                        'b01110: r <= 1000000;
                        'b01111: r <= 1001000;
                        'b10000: r <= 1111111; //(Space)
                        'b10001: r <= 0010010;
                        'b10010: r <= 0100000;
                        'b10011: r <= 0010001;
                        'b10100: r <= 0010010;
                        'b10101: r <= 1111111; //(Space)
                        'b10110: r <= 1111111; //(Space)
                        'b10111: r <= 1111111; //(Space)
                        'b11000: r <= 1111111; //(Space)
                        'b11001: r <= 1111111; //(Space)
                        'b11010: r <= 1111111; //(Space)
                        'b11011: r <= 1111111; //(Space)
                        'b11100: r <= 1111111; //(Space)
                        'b11101: r <= 1111111; //(Space)
                        'b11110: r <= 1111111; //(Space)
                        'b11111: r <= 1111111; //(Space)
                    endcase
                    inner <= inner + 1;
                    mr <= r;
                    ml <= mr;
                    l <= ml;
    end
	 
    always @(posedge clockFast)
    begin
        case(cnt)
        
        'b00: begin
                out <= r;
                an <= 4'b1110;
                cnt <= cnt + 1;
              end
        'b01: begin
                out <= mr;
                an <= 4'b1101;
                cnt <= cnt + 1;
              end
        'b10: begin
                out <= ml;
                an <= 4'b1011;
                cnt <= cnt + 1;
              end
        'b11: begin
                out <= l;
                an <= 4'b0111;
                cnt <= cnt + 1;
              end
              
        endcase
    end


endmodule
