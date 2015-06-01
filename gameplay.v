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

	// Clocks
    input clk, 			// Determined by level
	 input clk1Hz, 		// May not need
    input clkInit, 		// To set up the instructions
    input clockFast, 	// 500 Hz, cnt == 500 for 1 second
    input clockScroll,

    // States + random
    input [1:0] state,
    input [1:0] random,

    // Buttons
	input btnR,
	input btnM,
	input btnL,
	input btnU,
	input btnD,
	input hint,
	 
    // Outputs
    output reg [3:0] an,
    output reg [6:0] out,
	output reg newGame

    );
    

	// manages the reset to main-menu after a player ends their game
	// QUESTION: So we count to 10 and reset to main menu?
	// Josh: No, once the player loses, and after their high score input (if applicable)
	// we need to reset to the main menu. newGame should be triggered at the end of 
	// the high score function/game over function and immediately go to the main menu. 
	// This counts to 10 and resets newGame back to 0 so it doesn't stay 1.
	// We don't want to stay newGame forever and we can only change it in one always block...
	// I just realized, this reset of newGame needs to happen in whatever always block contains 
	// newGame down in the code below because we can't change it in more than one place.
	// just handle it below and know that we need to set newGame to reset to the main menu
	// and then turn newGame off after we've switched
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
			begin
				i <= i + 1;
			end
		end
	end
	 
	// Block memory variable declarations
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

    /******************** BEGIN JO ********************/

	// Use a 28 wide by 4 depth array to store the high score information
	// reg [27:0] highText = 28'b0001001100111110000100001001; // HIGH
	// reg [27:0] scorText = 28'b0010010100011010000001001100; // SCOR
	// reg [6:0] hsvalueText = 28'b1000000100000010000001000000;  // 0000

	reg [6:0] nameText0 = 7'b0100000;
	reg [6:0] nameText1 = 7'b0100000;
	reg [6:0] nameText2 = 7'b0100000;
	reg [6:0] nameText3 = 7'b1111111; 

	reg [6:0] hsvalueText0 = 7'b1000000;
	reg [6:0] hsvalueText1 = 7'b1000000;
	reg [6:0] hsvalueText2 = 7'b1000000;
	reg [6:0] hsvalueText3 = 7'b1000000;

	// Use a reg named hsCount to cycle through highScore
	reg [8:0] hsCount = 9'b000000000;
	reg [1:0] textSel = 2'b00;

	// Use a reg named newhsCount to cycle through: NEW HIGH SCOR (score) ENTR NAME AAA
	reg [8:0] newhsCount = 9'b000000000;
	reg [2:0] newhsTextSel = 3'b00;

	/*
		Use a reg named score to keep track of the player's score
		Each answer the player gets right, they get 1 point

		In addition, for each point the player gets right, please
		update a temphsvalueText.
		If score > old high score, we do the following:
		oldhs = score
		hsvalueText2 = temphsvalueText2
		hsvalueText3 = temphsvalueText3

		That way, you can reset score, and temphsvalueText 2 and 3
		to 0 and 7'b1000000 when the game has reset
		Also, set hsCount and newhsCount to 0 on reset
	*/ 

	// Initialize old high score to 0
	reg [5:0] oldhs = 6'b000000;
	reg [5:0] score = 6'b000000;

	// Temporary hsvalueText
	reg [6:0] temphsvalueText2 = 7'b1000000; // ten's column
	reg [6:0] temphsvalueText3 = 7'b1000000; // one's column

	/********************  END JO  ********************/
	 
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

	/******************** BEGIN JO ********************/

	// Use a 1 Hz clock
	// Use a simple counter to go through the states
	
	/*

	Can't use this block of code because changing out and an needs to occur
	in only one always block. Leaving here for reference.

	always @ (posedge clk1Hz) begin
		if (hsCount == 2'b00) begin
			out <= 'b1111111;
			an <= 'b1111; // we can't change out and an in another always block
			hsCount <= 2'b01;
		end
		else if (hsCount == 2'b01) begin

			hsCount <= 2'b10;
		end
		else if (hsCount == 2'b10) begin
			hsCount <= 2'b11;
		end
		else begin
			hsCount <= 2'b00;
		end
	end

	*/

	/********************  END JO  ********************/
	 


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
	reg prevHint = 0;

	 
	// handles going through the pattern at the appropriate clock speed
	always @ (posedge clk) begin
	if (state == 'b01 && index >= 50) // gameplay
			begin
				if (newRd == 1)
				begin
					timer <= 3;
					quickPause <= 'b10;
					newRd <= 0;
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
					   if (hint == 1 && prevHint == 0)
						begin
							newRd <= 1;
							display <= 1;
							max <= max - 1;
							prevHint <= 1;
						end
					
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
						else if ((hint == 0 && prevHint == 1) || mistake == 1 || timer == 0) // hint cheat or wrong button or time up
						begin
							timeUp <= 1;
							quickPause <= quickPause - 1;
							if (quickPause == 0)
							begin
								newRd <= 1;
								prevHint <= 0;
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
			mistake <= 0;
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
	 
	 
	 
	 
	 // welcome portion (merged from welcome.v)
    
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
    
    reg [4:0] inner = 0;
    
    
    always @(posedge clockScroll)
    begin
		if (state == 'b00)
		begin
                    case(inner)
                        'b00000: r <= 7'b1010101;
                        'b00001: r <= 7'b0000110;
                        'b00010: r <= 7'b1000111;
                        'b00011: r <= 7'b1000110;
                        'b00100: r <= 7'b1000000;
                        'b00101: r <= 7'b1101010;
                        'b00110: r <= 7'b0000110;
                        'b00111: r <= 7'b1111111; //(Space)
                        'b01000: r <= 7'b0000111;
                        'b01001: r <= 7'b1000000;
                        'b01010: r <= 7'b1111111; //(Space)
                        'b01011: r <= 7'b0010010;
                        'b01100: r <= 7'b1001111;
                        'b01101: r <= 7'b1101010;
                        'b01110: r <= 7'b1000000;
                        'b01111: r <= 7'b1001000;
                        'b10000: r <= 7'b1111111; //(Space)
                        'b10001: r <= 7'b0010010;
                        'b10010: r <= 7'b0100000;
                        'b10011: r <= 7'b0010001;
                        'b10100: r <= 7'b0010010;
                        'b10101: r <= 7'b1111111; //(Space)
                        'b10110: r <= 7'b1111111; //(Space)
                        'b10111: r <= 7'b1111111; //(Space)
                        'b11000: r <= 7'b1111111; //(Space)
                        'b11001: r <= 7'b1111111; //(Space)
                        'b11010: r <= 7'b1111111; //(Space)
                        'b11011: r <= 7'b1111111; //(Space)
                        'b11100: r <= 7'b1111111; //(Space)
                        'b11101: r <= 7'b1111111; //(Space)
                        'b11110: r <= 7'b1111111; //(Space)
                        'b11111: r <= 7'b1111111; //(Space)
                    endcase
                    inner <= inner + 1;
                    mr <= r;
                    ml <= mr;
                    l <= ml;
			end
    end
	 
	 
	reg [1:0] cnt = 'b00;

	// handles all displaying to Seven Seg Display
	always @ (posedge clockFast) begin

		if (state == 'b00)
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
		else if (state == 'b01 && index < 50)
		begin
			out <= 'b1111111;
			an <= 'b1111;
		end
		else if (state == 'b10)
		begin
			// TODO for Jo:
		    // put in the display logic here for the main menu High score stuff
		    case(textSel)
		    	'b00:
		    	begin
				    case(cnt)        
			        	'b00: begin
			                out <= 'b0001001; // H
			                an <= 4'b1110;
			      	       	cnt <= cnt + 1;
						end
			        	'b01: begin
			                out <= 'b1000010; // G
			                an <= 4'b1101;
			                cnt <= cnt + 1;
						end
			        	'b10: begin
			                out <= 'b1001111; // I
			                an <= 4'b1011;
			                cnt <= cnt + 1;
			            end
			        	'b11: begin
			                out <= 'b0001001; // H
			                an <= 4'b0111;
			                cnt <= cnt + 1;
			            end             
			        endcase
			    end
			    'b01:
		    	begin
				    case(cnt)        
			        	'b00: begin
			                out <= 'b1001100; // R
			                an <= 4'b1110;
			      	        cnt <= cnt + 1;
						end
			        	'b01: begin
			                out <= 'b1000000; // O
			                an <= 4'b1101;
			                cnt <= cnt + 1;
						end
			        	'b10: begin
			                out <= 'b1000110; // C
			                an <= 4'b1011;
			                cnt <= cnt + 1;
			            end
			        	'b11: begin
			                out <= 'b0010010; // S
			                an <= 4'b0111;
			                cnt <= cnt + 1;
			            end             
			        endcase
			    end
			    'b10:
		    	begin
				    case(cnt)        
			        	'b00: begin
			                out <= nameText3;
			                an <= 4'b1110;
			      	        cnt <= cnt + 1;
						end
			        	'b01: begin
			                out <= nameText2;
			                an <= 4'b1101;
			                cnt <= cnt + 1;
						end
			        	'b10: begin
			                out <= nameText1;
			                an <= 4'b1011;
			                cnt <= cnt + 1;
			            end
			        	'b11: begin
			                out <= nameText0;
			                an <= 4'b0111;
			                cnt <= cnt + 1;
			            end             
			        endcase
			    end
			    'b11:
		    	begin
				    case(cnt)        
			        	'b00: begin
			                out <= hsvalueText3;
			                an <= 4'b1110;
			      	        cnt <= cnt + 1;
						end
			        	'b01: begin
			                out <= hsvalueText2;
			                an <= 4'b1101;
			                cnt <= cnt + 1;
						end
			        	'b10: begin
			                out <= hsvalueText1;
			                an <= 4'b1011;
			                cnt <= cnt + 1;
			            end
			        	'b11: begin
			                out <= hsvalueText0;
			                an <= 4'b0111;
			                cnt <= cnt + 1;
			            end             
			        endcase
			    end
	        endcase

	        if (hsCount != 9'b111111111)
	        begin
	        	hsCount <= hsCount + 1;
	        end
	        else
	        begin
	        	hsCount <= 9'b000000000;
	        	textSel <= textSel + 1;
	        end
		end
		else if (gameOver == 1)
		begin
			// TODO for Jo:
			// put in the display logic here for the High score stuff at a game over
			/*
				TODO for Josh:
				Let me know your idea on this implementation. What should I add or remove?
				Also, what variable stores the score?
				
				Josh: This looks good to me. So I guess you would flash NEW, HIGH, SCOR, ENTR, NAME, and then
				at the AAA, the user would begin their initial selection. Make sure the user is not able to change their initials until 
				they're displayed on the seven seg. I would recommend having two states, one for the display, then one for the user input. 
				Button pushes only do something in the latter state
				Also I didn't create a score register yet so you can just create one
				
				Implement:
				1. If score > high_score, set high_score = score
				   Then, change values of hsvalueText 0 through 3 (0 = l, 1 = ml, 2 = mr, 3 = r)
				   Display:
						NEW     0
						HIGH 	1
						SCOR 	2
						(score) 3
						ENTR	4
						NAME 	5
						AAA 	6
							Then, allow user to input their initials
							(Up = Go backwards in the alphabet)
							(Down = Go forwards in the alphabet)
							(Left = Go left on initials)
							(Right = Go right on the initials)
							(Center = Submit initials) 
				2. Else, 
					Display:
						YOUR
						SCOR
						(Score)
			*/

			if (score > oldhs)
			begin
				oldhs = score;
				hsvalueText2 = temphsvalueText2;
				hsvalueText3 = temphsvalueText3;

				case(newhsTextSel)
			    	'b000:
			    	begin
					    case(cnt)        
				        	'b00: begin
				                out <= 'b1111111; // Space
				                an <= 4'b1110;
				      	       	cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b1010101; // W
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin
				                out <= 'b0000110; // E
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b1001000; // N
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				    'b001:
			    	begin
					    case(cnt)        
				        	'b00: begin
				                out <= 'b0001001; // H
				                an <= 4'b1110;
				      	       	cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b1000010; // G
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin
				                out <= 'b1001111; // I
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b0001001; // H
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				    'b010:
			    	begin
					    case(cnt)        
				        	'b00: begin
				                out <= 'b1001100; // R
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b1000000; // O
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin
				                out <= 'b1000110; // C
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b0010010; // S
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				    b'011:
				    begin
				    	case(cnt)        
				        	'b00: begin
				                out <= temphsvalueText3; // one's column
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= temphsvalueText2; // ten's column
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin				        	
				                out <= 'b1000000; // 0
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b1000000; // 0 
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				    b'100:
				    begin
				    	case(cnt)        
				        	'b00: begin
				                out <= 'b1001100; // R
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b0000111; // T
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin				        	
				                out <= 'b1001000; // N
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b0000110; // E
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				    b'101:
				    begin
				    	case(cnt)        
				        	'b00: begin
				                out <= 'b0000110; // E
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b1101010; // M
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin				        	
				                out <= 'b0100000; // A
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b1001000; // N
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				    b'110:
				    begin
				    	case(cnt)        
				        	'b00: begin
				                out <= 'b1111111; // Space
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b0100000; // A
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin				        	
				                out <= 'b0100000; // A
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b0100000; // A
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
				    end
				endcase
			end
			else
			begin
				case (newTextSel)
					'b000:
						case(cnt)        
				        	'b00: begin
				                out <= 'b1001100; // R
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b1000001; // U
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin				        	
				                out <= 'b1000000; // O
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b0010001; // Y
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
					begin
					end
					'b001:
					begin
						case(cnt)        
				        	'b00: begin
				                out <= 'b1001100; // R
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= 'b1000000; // O
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin
				                out <= 'b1000110; // C
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b0010010; // S
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
					end
					'b010:
					begin
						case(cnt)        
				        	'b00: begin
				                out <= temphsvalueText3; // one's column
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				                out <= temphsvalueText2; // ten's column
				                an <= 4'b1101;
				                cnt <= cnt + 1;
							end
				        	'b10: begin				        	
				                out <= 'b1000000; // 0
				                an <= 4'b1011;
				                cnt <= cnt + 1;
				            end
				        	'b11: begin
				                out <= 'b1000000; // 0 
				                an <= 4'b0111;
				                cnt <= cnt + 1;
				            end             
				        endcase
					end
				endcase
			end


			/*	
				Cycle through to display NEW, HIGH, SCOR, (score), ENTR, NAME
				Stops incrementing nshsTextSel at 6
			*/
			if (newhsCount != 9'b111111111)
	        begin
	        	newhsCount <= newhsCount + 1;
	        end
	        else if (newhsTextSel < 6)
	        begin
	        	newhsCount <= 9'b000000000;
	        	newhsTextSel <= newhsTextSel + 1;
	        end
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
