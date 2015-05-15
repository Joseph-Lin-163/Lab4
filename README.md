# Lab4

Files authored by Joseph Lin:\n
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
