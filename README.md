# Lab4

Files authored by Joseph Lin:

1. coefilegen.cpp coefilegen test.coe

2. verify.cpp verify verified.txt

coefilegen.cpp produces a COE file for block memory.

Requires 1400 by 8 bits of memory (11200 total bits)

Produces instructions to be outputed to the seven-segment display

Format: 

Every 28 bits is divided into 4 pieces (1 piece per display - 4 displays total)

First seven bits belong to an[0]

Second seven bits belong to an[1]

Third seven bits belong to an[2]

Fourth seven bits belong to an[3]

verify.cpp produces an executable (verify, in this case) that checks

to make sure that the COE file did indeed output the instructions properly.

I pattern matched the seven-segment code to their proper instructions

The output is what we expect

Files authored by Josh

master.v - links everything together for simulation

masterCLK.v - creates all the clocks necessary for the levels' difficulty, scrolling, blinking... everything

levels.v - determines what level difficulty the user selects through the 8 switches

mainMenu.v - determines the navigation between the main menu screen, high score screen, and game screen

TODO:

Program all the logic for the game 

  -Displaying the pattern for every round
  
  -Flashing the user's move for every correct button (e.g. UP will flash on the screen if the user pushes UP)
  
  -Displaying LOSE if the user pushes the wrong button for the next pattern direction or waits too long to input the pattern
  
  -Inputting their initials for the high score if they qualify at the end of their game
  
Program the high score screen display

  -Flash between HIGH SCORE AAA 00
  
Program the scrolling welcome message
