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
	string welcome[7] = {"1010101000011010001111000110","1000000110101000001101111111","0000111100000011111110010010","1001111110101010000001001000",
							"1111111001001001000000010001","0010010111111111111111111111","1111111111111111111111111111"};

	cin >> s;
	for (int i = 0; i < 50; i++) {
		for (int j = 0; j < 7; j++) {
			for (int k = 0; k < 28; k++) {
				if (s[28*i + k] != welcome[j][k]) {
					break;
				}
				else if (k == 27) {
					if (j == 0) {
						cout << "welc";
					}
					else if (j == 1) {
						cout << "ome ";
					}
					else if (j == 2) {
						cout << "to s";
					}
					else if (j == 3) {
						cout << "imon";
					}
					else if (j == 4) {
						cout << " say";
					}
					else if (j == 5) {
						cout << "s   ";
					}
					else if (j == 6) {
						cout << "    ";
					}

				}
			}
		}
	}
	
	cout << "\n";

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