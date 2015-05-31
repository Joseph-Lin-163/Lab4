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
    input clk, // clk from the appropriate level speed
    input clkInit,
    input [1:0] state,
    input [1:0] random,
	 input btnR,
	 input btnM,
	 input btnL,
	 input btnU,
	 input btnD,
	 
    input clockFast,
    output reg [3:0] an,
    output reg [6:0] out,
	 output reg newGame

    );
    

	 // manages the reset to main-menu after a player ends their game
	 integer i = 0;
	 always @ (posedge clkInit)
	 begin
		if (newGame == 1)
		begin
			if (i == 10)
			begin
				newGame <= 0;
				i <= 0;
			end
			else
				i <= i + 1;
		end
	 end
	 
	 
    reg [27:0] assigne [49:0]; // 2D array
    integer index = 0;
    reg [7:0] sel0 = 0 * 'b110010; // 50 offset
    reg [7:0] sel1 = 1 * 'b110010; // 50 offset
    reg [7:0] sel2 = 2 * 'b110010; // 50 offset
    reg [7:0] sel3 = 3 * 'b110010; // 50 offset
    wire [27:0] outa0;
	 wire [27:0] outa1;
	 wire [27:0] outa2;
	 wire [27:0] outa3;


    block_mem bm0(
        .clka(clk),
        .wea(1'b0),
        .addra(sel0),
        .dina(28'b0),
        .douta(outa0)
    );
	 block_mem bm1(
        .clka(clk),
        .wea(1'b0),
        .addra(sel1),
        .dina(28'b0),
        .douta(outa1)
    );
	 block_mem bm2(
        .clka(clk),
        .wea(1'b0),
        .addra(sel2),
        .dina(28'b0),
        .douta(outa2)
    );
	 block_mem bm3(
        .clka(clk),
        .wea(1'b0),
        .addra(sel3),
        .dina(28'b0),
        .douta(outa3)
    );
	 
	 reg gameOver = 0;
		 
    // grabbing the pattern from block memory at the start
    always @ (posedge clkInit) begin
		if (gameOver == 1)
		begin
			index <= 0;
		end
		if (state == 'b01 && index < 50) 
		begin
        sel0 <= sel0 + 1; 
		  sel1 <= sel1 + 1;
		  sel2 <= sel2 + 1;
		  sel3 <= sel3 + 1;
		  index <= index + 1;
		  case(random)
				2'b00: assigne[index] <= outa0;
				2'b01: assigne[index] <= outa1;
				2'b10: assigne[index] <= outa2;
				2'b11: assigne[index] <= outa3;
		  endcase
		end
	 end
    

	 
	 // TODO for Jo: 
	 // The player is in the main menu screen and they just pushed button R to navigate
	 // to the high score screen. 
	 // display the alternating High Score, AAA 00, for whatever high score is currently there
	 /*
	  always @ (posedge )// whatever clk you want to use
	  //you'll need a clk to switch between the High Score, initials and score 
	  if (state == 'b10) // high score state of Main Menu
	  begin
			// logic here
	  end
	 */
	 reg display = 1;
	 reg on = 0;
	 reg [5:0] loop = 'b000000;
	 reg [5:0] max = 'b000101; // TODO: change back when testing done
	 reg [27:0] msg = 'b1111111111111111111111111111;	// blank initial message
	 integer timer = 3;
	 reg allCorrect = 0;
	 reg [1:0] quickPause = 'b10;
	 reg newRd = 0;
	 reg timeUp = 0;
	 reg mistake = 0;

	 
	 // handles going through the pattern at the appropriate clock speed
	 always @ (posedge clk) begin
	 if (state == 'b01 && index >= 50) // gameplay
			begin
				if (newRd == 1)
				begin
					timer <= 3;
					quickPause <= 'b10;
					newRd <= 0;
					mistake <= 0;
				end
			else
				begin
					if (display == 1) // pattern display
					begin
						if (on == 0)
						begin
							on <= 1;
					   end
						else
						begin
							// loop through pattern
							if (loop < max)
								loop <= loop + 1;
							else
							begin
								loop <= 0;
								max <= max + 1;
								display <= 0;
							end
							on <= 0;
					   end
						timer <= timer + 3;
					end
					else // player should be putting in the pattern
					begin
						if (allCorrect == 1)
						begin
							// player successfully inputted the whole pattern
							quickPause <= quickPause - 1;
							if (quickPause == 0)
							begin
								newRd <= 1;
								display <= 1;
							end
						end
						else if (timer > 0)
							timer <= timer - 1;
						else if (mistake == 1 || timer == 0) // wrong button or time up
						begin
							timeUp <= 1;
							quickPause <= quickPause - 1;
							if (quickPause == 0)
							begin
								newRd <= 1;
								display <= 1;
								gameOver <= 1;
								// high score = max - 1
							end
						
						end
						
					end
				end
			end
	 end
	 
	 	     
	 /*
	 UP:   1000001000110011111111111111
	 DOWN: 1000000100000010101011001000
	 LEFT: 1000111000011000011100000111
	 RITE: 1001100111100100001110000110
	 MID:  1101010111100110000001111111
	 */
	 
	 integer verify = 0;
	 reg [5:0] numRight = 0;
	 reg press = 0;
	 reg correct = 0;

	 
	 // works in conjunction with the previous always block to grab the player input and verify it against the displayed pattern
	 always @ (posedge clkInit) begin
	   if (newRd == 1)
		begin
			verify <= 0;
			numRight <= 'b000000;
			press <= 0;
			correct <= 0;
			allCorrect <= 0;
		end
		else if (state == 'b01 && display == 0)
		begin
			if (numRight == max - 1)
			begin
				msg <= 'b1000010100000010000000100001; // 'GOOD'
				allCorrect <= 1;
			end
			else if (timeUp == 1)
			begin
				msg <= 'b1000111100000000100100000110; // 'LOSE'
			end
			else if (btnR && assigne[verify] == 'b1001100111100100001110000110 && ~btnM && ~btnL && ~btnU && ~btnD)
			begin
				press <= 1;
				correct <= 1;
				msg <= 'b1001100111100100001110000110;
			end
			else if (btnM && assigne[verify] == 'b1101010111100110000001111111 && ~btnR && ~btnL && ~btnU && ~btnD)
			begin
				press <= 1;
				correct <= 1;
				msg <= 'b1101010111100110000001111111;
			end
			else if (btnL && assigne[verify] == 'b1000111000011000011100000111 && ~btnM && ~btnR && ~btnU && ~btnD)
			begin
				press <= 1;
				correct <= 1;
				msg <= 'b1000111000011000011100000111;
			end
			else if (btnU && assigne[verify] == 'b1000001000110011111111111111 && ~btnM && ~btnL && ~btnR && ~btnD)
			begin
				press <= 1;
				correct <= 1;
				msg <= 'b1000001000110011111111111111;
			end
			else if (btnD && assigne[verify] == 'b1000000100000010101011001000 && ~btnM && ~btnL && ~btnU && ~btnR)
			begin
				press <= 1;
				correct <= 1;
				msg <= 'b1000000100000010101011001000;
			end
			else if (~btnD && ~btnM && ~btnL && ~btnU && ~btnR) // no button is pressed
			begin
				press <= 0;
				msg <= 'b1111111111111111111111111111; // blank
			end
			else // player pushed the wrong button
			begin
				press <= 1;
				mistake <= 1;
				msg <= 'b1000111100000000100100000110; // 'LOSE'
			end
			
			if (press == 0)
			begin
				if (correct == 1)
				begin
					numRight <= numRight + 1;
					verify <= verify + 1;
					correct <= 0;
				end
			end
			
		end
	 end
	 
	 
	 // TODO for Jo:
	 // the player just lost so you need to input the logic for checking their high score against the current
	 // high score and have them input their initials
	 /*
	 always @ (posedge ) 
	 if (gameOver == 1)
	 begin
	 
	 
	 newGame <= 1;
	 end
	 */
	 
	 
	 
	 
	 reg [1:0] cnt = 'b00;

	 // handles all displaying to Seven Seg Display
	 always @ (posedge clockFast) begin
	 if (state == 'b01 && index < 50)
	 begin
			out <= 'b1111111;
			an <= 'b1111;
	 end
	 else if (state == 'b10)
	 begin
			// TODO for Jo:
		   // put in the display logic here for the main menu High score stuff
	 end
	 else if (gameOver == 1)
	 begin
			// TODO for Jo:
			// put in the display logic here for the High score stuff at a game over
	 end
		else if (on == 0)
		  begin
				if (display == 1)		// displaying pattern
				begin
					out <= 7'b1111111;	// blank
					an <= 4'b1111;
				end
				else						// player inputting pattern
				begin
					case(cnt)
        
					'b00: begin
								out <= msg[6:0];
								an <= 4'b1110;
								cnt <= cnt + 1;
							end
					'b01: begin
								out <= msg[13:7];
								an <= 4'b1101;
								cnt <= cnt + 1;
							end
					'b10: begin
								out <= msg[20:14];
								an <= 4'b1011;
								cnt <= cnt + 1;
							end
					'b11: begin
								out <= msg[27:21];
								an <= 4'b0111;
								cnt <= cnt + 1;
							end
					endcase
				end
		  end
		  else	// displaying pattern the user must copy
		  begin
				case(cnt)
        
				'b00: begin
							out <= assigne[loop][6:0];
							an <= 4'b1110;
							cnt <= cnt + 1;
						end
				'b01: begin
							out <= assigne[loop][13:7];
							an <= 4'b1101;
							cnt <= cnt + 1;
						end
				'b10: begin
							out <= assigne[loop][20:14];
							an <= 4'b1011;
							cnt <= cnt + 1;
						end
				'b11: begin
							out <= assigne[loop][27:21];
							an <= 4'b0111;
							cnt <= cnt + 1;
						end
              
				endcase
	    end
	 end

endmodule
