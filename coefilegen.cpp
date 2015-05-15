#include <iostream>
#include <stdlib.h>

using namespace std;

int main() {

	string mid = "1101010111100110000001111111";
	string rite = "1001100111100100001110000110";
	string left = "1000111000011000011100000111";
	string down = "1000000100000010101011001000";
	string up = "1000001000110011111111111111";
	cout << "memory_initialization_radix=2;\nmemory_initialization_vector=\n";
	for (int i = 0; i < 8; i++) {
		for (int j = 0; j < 1400; j+= 28) {
			int choose = rand() % 5;
			if (choose == 0) {
				cout << mid;
			}
			else if (choose == 1) {
				cout << rite;
			}
			else if (choose == 2) {
				cout << left;
			}
			else if (choose == 3) {
				cout << down;
			}
			else {
				cout << up;
			}
		}
		
		if (i < 7)
			cout << ",\n";
		else
			cout << "\n";
	}
}

/* 
	Summary
	1st: mid
	2nd: top left
	3rd: bottom left
	4th: bottom
	5th: bottom right
	6th: top right
	7th: top

	MID  = 1101010 | 1111001 | 1000000 | 1111111 
	RITE = 1001100 | 1111001 | 0000111 | 0000110
	LEFT = 1000111 | 0000110 | 0001110 | 0000111
	DOWN = 1000000 | 1000000 | 1010101 | 1001000
	UP   = 1000001 | 0001100 | 1111111 | 1111111

	28 bits to represent instruction
	Assume 50 instructions max
	Requires 1400 bits
*/