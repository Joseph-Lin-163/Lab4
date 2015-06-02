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
module gameplay(
//////////////////////////////////////////////////////////////////////////////////

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
	output reg newGameFlag

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
	/*

	Joseph:
	I'm commenting this out for safety.
	I have a newGameFlag set in my high score work.
	When the person pressed the middle button to signify they are done inputting their initials,
	the newGameFlag is set to 1. During that time, gameOver needs to be set to 0.
	If I need to reset newGameFlag to 0, I can visit the same always block that contains the 
	assignment of newGameFlag and make a case for gameOver == 0 && newGameFlag == 1 to reset
	newGameFlag back to 0.

	TODO: Josh, I need your input on where to place the logic below. I'm a bit brain dead right
	now and I think I had better consult you for your idea on the code architecture.
    
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
	*/ 

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
	reg [6:0] hsCount = 5'b00000;
	reg [1:0] textSel = 2'b00;
 
	// Use a reg named newhsCount to cycle through: NEW HIGH SCOR (score) ENTR NAME AAA
	reg [6:0] newhsCount = 5'b00000;
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

	// Initialize a var to keep track of which initial I'm on
	reg [1:0] trackInitial = 2'b00;
	reg [4:0] letterSel = 5'b00000;

	// Initialize a flag to let the game know to move back to the newGame
	//reg [0:0] newGameFlag = 'b0;

	// Initialize the alphabet
	reg [6:0] alphabet0 = 7'b0100000;
	reg [6:0] alphabet1 = 7'b0000011;
	reg [6:0] alphabet2 = 7'b1000110;
	reg [6:0] alphabet3 = 7'b0100001;
	reg [6:0] alphabet4 = 7'b0000110;
	reg [6:0] alphabet5 = 7'b0001110;
	reg [6:0] alphabet6 = 7'b1000010;
	reg [6:0] alphabet7 = 7'b0001001;
	reg [6:0] alphabet8 = 7'b1001111;
	reg [6:0] alphabet9 = 7'b1100001;
	reg [6:0] alphabet10 = 7'b0001010;
	reg [6:0] alphabet11 = 7'b1000111;
	reg [6:0] alphabet12 = 7'b1101010;
	reg [6:0] alphabet13 = 7'b1001000;
	reg [6:0] alphabet14 = 7'b1000000;
	reg [6:0] alphabet15 = 7'b0001100;
	reg [6:0] alphabet16 = 7'b0011000;
	reg [6:0] alphabet17 = 7'b1001100;
	reg [6:0] alphabet18 = 7'b0010010;
	reg [6:0] alphabet19 = 7'b0000111;
	reg [6:0] alphabet20 = 7'b1000001;
	reg [6:0] alphabet21 = 7'b1010001;
	reg [6:0] alphabet22 = 7'b1010101;
	reg [6:0] alphabet23 = 7'b0001001;
	reg [6:0] alphabet24 = 7'b0010001;
	reg [6:0] alphabet25 = 7'b0110100;
	

	/********************  END JO  ********************/
	 
	reg gameOver = 0;
		 
    // grabbing the pattern from block memory at the start
    always @ (posedge clkInit) begin
		if (gameOver == 1)
		begin
			index <= 0;
		end
		else if (state == 'b01 && index < 50) 
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
	reg [5:0] max = 'b001001; 
	reg [27:0] msg = 'b1111111111111111111111111111;	// blank initial message
	integer timer = 3;
	reg allCorrect = 0;
	reg [2:0] quickPause = 'b111;
	reg newRd = 0;
	reg timeUp = 0;
	reg mistake = 0;
	reg prevHint = 0;

	 
	// handles going through the pattern at the appropriate clock speed
	always @ (posedge clk) begin
    if (gameOver == 1 && score > 0 && (textSel == 0 || newhsTextSel == 0))
    begin
                                if (score >= 'b010100) // 20
                                begin
                                    temphsvalueText2 <= 'b0100100; // 2
                                    if ((score - 'b010100) == 'b001001) // 9
                                        temphsvalueText3 <= 'b0011000;
                                    else if ((score - 'b010100) == 'b001000) // 8
                                        temphsvalueText3 <= 'b0000000;
                                    else if ((score - 'b010100) == 'b000111) // 7
                                        temphsvalueText3 <= 'b1111000;
                                    else if ((score - 'b010100) == 'b000110) // 6
                                        temphsvalueText3 <= 'b0000010;
                                    else if ((score - 'b010100) == 'b000101) // 5
                                        temphsvalueText3 <= 'b0010010;
                                    else if ((score - 'b010100) == 'b000100) // 4
                                        temphsvalueText3 <= 'b0011001;
                                    else if ((score - 'b010100) == 'b000011) // 3
                                        temphsvalueText3 <= 'b0110000;
                                    else if ((score - 'b010100) == 'b000010) // 2
                                        temphsvalueText3 <= 'b0100100;
                                    else if ((score - 'b010100) == 'b000001) // 1
                                        temphsvalueText3 <= 'b1111001;
                                    else if ((score - 'b010100) == 'b000000) // 0
                                        temphsvalueText3 <= 'b1000000;
                                end
                                else if (score >= 'b001010) // 10
                                begin
                                    temphsvalueText2 <= 'b1111001; // 1
                                    if ((score - 'b001010) == 'b001001) // 9
                                        temphsvalueText3 <= 'b0011000;
                                    else if ((score - 'b001010) == 'b001000) // 8
                                        temphsvalueText3 <= 'b0000000;
                                    else if ((score - 'b001010) == 'b000111) // 7
                                        temphsvalueText3 <= 'b1111000;
                                    else if ((score - 'b001010) == 'b000110) // 6
                                        temphsvalueText3 <= 'b0000010;
                                    else if ((score - 'b001010) == 'b000101) // 5
                                        temphsvalueText3 <= 'b0010010;
                                    else if ((score - 'b001010) == 'b000100) // 4
                                        temphsvalueText3 <= 'b0011001;
                                    else if ((score - 'b001010) == 'b000011) // 3
                                        temphsvalueText3 <= 'b0110000;
                                    else if ((score - 'b001010) == 'b000010) // 2
                                        temphsvalueText3 <= 'b0100100;
                                    else if ((score - 'b001010) == 'b000001) // 1
                                        temphsvalueText3 <= 'b1111001;
                                    else if ((score - 'b001010) == 'b000000) // 0
                                        temphsvalueText3 <= 'b1000000;
                                end
                                else
                                begin
                                    if ((score) == 'b001001) // 9
                                        temphsvalueText3 <= 'b0011000;
                                    else if ((score) == 'b001000) // 8
                                        temphsvalueText3 <= 'b0000000;
                                    else if ((score) == 'b000111) // 7
                                        temphsvalueText3 <= 'b1111000;
                                    else if ((score) == 'b000110) // 6
                                        temphsvalueText3 <= 'b0000010;
                                    else if ((score) == 'b000101) // 5
                                        temphsvalueText3 <= 'b0010010;
                                    else if ((score ) == 'b000100) // 4
                                        temphsvalueText3 <= 'b0011001;
                                    else if ((score) == 'b000011) // 3
                                        temphsvalueText3 <= 'b0110000;
                                    else if ((score) == 'b000010) // 2
                                        temphsvalueText3 <= 'b0100100;
                                    else if ((score) == 'b000001) // 1
                                        temphsvalueText3 <= 'b1111001;
                                    else if ((score) == 'b000000) // 0
                                        temphsvalueText3 <= 'b1000000;
                                end
                                
    end
    else if (gameOver == 1 && score < oldhs && newhsTextSel >= 'b011)
    begin
        gameOver <= 0;
        max <= 'b000001; 
        score <= 0;
        temphsvalueText2 <= 'b1000000;
        temphsvalueText3 <= 'b1000000;
    end
    else if (gameOver == 1 && score >= oldhs && newGameFlag == 1)
    begin
        gameOver <= 0;
        max <= 'b000001; 
        score <= 0;
        temphsvalueText2 <= 'b1000000;
        temphsvalueText3 <= 'b1000000;
    end
	 if (state == 'b01 && index >= 50 && gameOver == 0) // gameplay
			begin
				if (newRd == 1)
				begin
					timer <= 3;
					quickPause <= 'b111;
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
							if (loop < max - 1) // because on is 1, it will display the final loop even if condition is false
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
								score <= max - 2;
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
	   if (newRd == 1 || gameOver == 1)
		begin
			verify <= 0;
			numRight <= 'b000000;
			press <= 0;
			correct <= 0;
			allCorrect <= 0;
			mistake <= 0;
			msg <= 'b1111111111111111111111111111; // blank
		end
		else if (state == 'b01 && display == 0)
		begin
		   if (timeUp == 1)
			begin
				msg <= 'b1000111100000000100100000110; // 'LOSE'
			end
			else if (numRight == max - 1)
			begin
				msg <= 'b1000010100000010000000100001; // 'GOOD'
				allCorrect <= 1;
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
	 if (gameOver == 1 )
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
    
    reg [6:0] r = 'b1111111;
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

				/* Josh: so the clock here is already fast enough so you could put the code here or in another
				     always block to keep things more organized, I would do the latter for readability. I imagine it
				     would look something like:
				     always @(posedge clockFast) begin
				     if (gameOver == 1)
				     begin
				     	case(letterSel)
				     		'b00000: begin
				     			  letter <= 'b0100000; // A
				     			  end
				                'b00001: //all the others
				                // ...
				                endcase
				                if (letterSel == 'b000000 && btnD == 1)
				                	letterSel <= ('b11010); // last letter
				                else if (btnU == 1 && btnUPrev == 0) // prev is so you don't sweep through the letters
				                			 	// really fast through one button push
				                begin
				                	letterSel <= letterSel + 1;
				                	btnUPrev <= 1;
				                end
				                
				                if (btnU == 0)
				                	btnUPrev <= 0;
				                	
				                // do the same for btnD
				       end
				     end
				     
				     // inside the display do something like
				     if (clockBlink == 1)
				     	out <= 'b1111111; // blank
				     else
				     	out <= letter;
				     	*/


	reg [0:0] btnDPrev = 'b0;
	reg [0:0] btnUPrev = 'b0;
	reg [0:0] btnRPrev = 'b0;
	reg [0:0] btnMPrev = 'b0;
	reg [0:0] btnLPrev = 'b0;

	// handles inputting the name
	always @ (posedge clockFast) 
	begin
    if (gameOver == 0)
    begin
        newGameFlag <= 'b0; // TODO: newGameFlag not maintained for long enough
    end
		// Don't allow change unless gameOver + score >= oldhs + newhsTextSel is showing initials
		if (gameOver == 1 && score >= oldhs && newhsTextSel >= 'b101) begin
			case(trackInitial)
				'b00:
				begin
					case (letterSel)
						'b00000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet1;
								btnDPrev <= 'b1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet2;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet0;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;								
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet3;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet1;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet4;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet2;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet5;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet3;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet6;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet4;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet7;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet5;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b00111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet8;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet6;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet9;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet7;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet10;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet8;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet11;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet9;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet12;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet10;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet13;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet11;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet14;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet12;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet15;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet13;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b01111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet16;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet14;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet17;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet15;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet18;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet16;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet19;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet17;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet20;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet18;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet21;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet19;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet22;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet20;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet23;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet21;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b10111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet24;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet22;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b11000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText0 <= alphabet25;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet23;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
						'b11001:
						begin							
							if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText0 <= alphabet24;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
						end
					endcase
				end
				'b01:
				begin
					case (letterSel)
						'b00000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet1;
								btnDPrev <= 'b1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end							
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet2;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet0;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet3;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet1;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet4;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet2;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet5;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet3;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet6;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet4;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet7;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet5;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet8;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet6;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet9;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet7;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet10;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet8;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet11;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet9;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet12;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet10;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet13;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet11;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet14;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet12;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet15;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet13;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet16;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet14;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet17;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet15;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet18;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet16;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet19;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet17;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet20;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet18;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet21;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet19;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet22;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet20;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet23;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet21;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet24;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet22;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b11000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText1 <= alphabet25;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet23;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b11001:
						begin
							if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText1 <= alphabet24;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnR == 1 && btnRPrev == 0)
							begin
								btnRPrev <= 1;
								trackInitial <= trackInitial + 1;
							end

							if (btnR == 0)
							begin
								btnRPrev <= 0;
							end
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;						
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
						end
					endcase
				end
				'b10:
				begin
					case (letterSel)
						'b00000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet1;
								btnDPrev <= 'b1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial - 1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
						end
						'b00001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet2;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet0;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
						end
						'b00010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet3;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet1;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet4;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet2;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet5;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet3;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet6;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet4;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet7;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet5;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b00111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet8;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet6;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet9;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet7;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet10;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet8;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet11;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet9;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet12;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet10;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet13;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet11;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet14;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet12;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet15;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet13;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b01111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet16;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet14;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet17;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet15;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10001:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet18;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet16;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10010:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet19;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet17;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10011:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet20;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet18;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10100:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet21;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet19;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10101:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet22;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet20;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10110:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet23;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet21;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b10111:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet24;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet22;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end

							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b11000:
						begin
							if (btnD == 1 && btnDPrev == 0)
							begin
								letterSel <= letterSel + 1;
								nameText2 <= alphabet25;
								btnDPrev <= 'b1;
							end
							else if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet23;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
						end
						'b11001:
						begin							
							if (btnU == 1 && btnUPrev == 0)
							begin
								letterSel <= letterSel - 1;
								nameText2 <= alphabet24;
								btnUPrev <= 'b1;
							end
							else if (btnM == 1 && btnMPrev == 0)
							begin
								btnMPrev <= 1;
								newGameFlag <= 1;
							end
							else if (btnL == 1 && btnLPrev == 0)
							begin
								btnLPrev <= 1;
								trackInitial <= trackInitial -1;								
							end
							
							if (btnL == 0)
							begin
								btnLPrev <= 'b0;
							end
							if (btnR == 0)
							begin
								btnRPrev <= 'b0;
							end
							if (btnM == 0)
							begin
								newGameFlag <= 0;
								btnMPrev <= 'b0;
							end
							if (btnU == 0)
							begin
								btnUPrev <= 'b0;
							end
							if (btnD == 0)
							begin
								btnDPrev <= 'b0;
							end
						end
					endcase
				end
			endcase
		end 
        else if (gameOver == 1 && score < oldhs)
        begin
            if (newhsTextSel == 'b011)
            begin
                newGameFlag <= 1;
            end
        end
        else // gameOver == 0
        begin
            newGameFlag <= 0;
        end
	end

    
	// handles all displaying to Seven Seg Display
	always @ (posedge clockFast) begin

		if (state == 'b00)
		begin
                newhsTextSel <= 'b000;
                newhsCount <= 5'b00000;
                hsCount <= 5'b00000;
                textSel <= 'b00;
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

	        if (hsCount != 5'b11111)
	        begin
	        	hsCount <= hsCount + 1;
	        end
	        else
	        begin
	        	hsCount <= 5'b00000;
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

			if (score >= oldhs)
			begin
				oldhs <= score;
				hsvalueText2 <= temphsvalueText2;
				hsvalueText3 <= temphsvalueText3;

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
				    'b011:
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
				    'b100:
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
				    'b101:
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
				    'b110:				 				     
				    begin
				    	case(cnt)        
				        	'b00: begin
				                out <= 'b1111111; // Space
				                an <= 4'b1110;
				      	        cnt <= cnt + 1;
							end
				        	'b01: begin
				        	// out <= letter; // change to take in the variable you're selecting from above
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
				endcase
			end
			else
			begin
				case (newhsTextSel)
					'b000:
					begin
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
			if (newhsCount != 5'b11111)
	        begin
	        	newhsCount <= newhsCount + 1;
	        end
	        else if (newhsTextSel < 'b110)
	        begin
	        	newhsCount <= 5'b00000;
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
