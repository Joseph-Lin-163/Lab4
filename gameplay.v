`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:15:43 05/27/2015 
// Design Name: 
// Module Name:    gameplay 
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
module gameplay(
    input clk,
    input clkInit,
    input [1:0] state
    
    );
    
    reg dummy;
    reg [27:0] dummyin;
    reg [27:0] assigne [49:0]; // 2D array
    integer index = -1;
    reg [7:0] sel0 = 0 * 'b110010; // 50 offset
    reg [7:0] sel1 = 1 * 'b110010; // 50 offset
    reg [7:0] sel2 = 2 * 'b110010; // 50 offset
    reg [7:0] sel3 = 3 * 'b110010; // 50 offset
    wire [27:0] douta;
    reg [6:0] cnt = 0;
    
    block_mem bm(
        .clka(clk),
        .wea(1'b0),
        .addra(sel0),
        .dina(28'b0),
        .douta(douta)
    );

    
    always @ (posedge clkInit) begin
	if (cnt < 'b110010) // < 50
    begin
        sel0 <= sel0 + 1; 
		index <= index + 1;
        cnt <= cnt + 1;
		assigne[index] <= douta;
    end
    /*
    if (state ==  'b00)
        // game logic
        
     if (state == 'b10)
        // high score logic
     else
        // don't do anything
       */ 
    end
endmodule
