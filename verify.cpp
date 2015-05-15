#include <iostream>
#include <string>
using namespace std;

int main() {
	string s;
	cin >> s;
	cin >> s;
	// get rid of first two lines

	string instr[5] = {"1101010111100110000001111111","1001100111100100001110000110","1000111000011000011100000111",
			"1000000100000010101011001000","1000001000110011111111111111"};
	
	/*
	string mid = ;
	string rite = ;
	string left = ;
	string down = ;
	string up = ;
	*/

	for (int i = 0; i < 8; i++) {
		cin >> s;
		for (int j = 0; j < 50; j++) {
			for (int k = 0; k < 5; k++) {
				for (int h = 0; h < 28; h++) {
					if (instr[k][h] != s[j*28 + h])
						break;
					else if ( h == 27 ) {
						if (k == 0) {
							cout << "mid ";
						}
						else if (k == 1) {
							cout << "rite ";
						}
						else if (k == 2) {
							cout << "left ";
						}
						else if (k == 3) {
							cout << "down ";
						}
						else {
							cout << "up ";
						}
					}
				}
			}
		}
		cout << "\n";
	}
}