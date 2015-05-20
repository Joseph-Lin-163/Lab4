#include <iostream>
#include <string>

using namespace std;

string toBin(int num) {
	// Going to be an 8-bit
	string s;

	/*
		128 64 32 16 8 4 2 1
	*/
	int a[8] = {128,64,32,16,8,4,2,1};
	for (int i = 0; i < 8; i++) {
		if (num - a[i] < 0) {
			s += '0';
		}
		else {
			s += '1';
			num -= a[i];
		}
	}
	return s;
}

int main() {

	for (int i = 0; i < 50; i++) {
		cout << "reg [27:0] assign" << i << ";" << "\n";
	}

	for (int i = 0; i < 50; i++) {
		cout << "addra[" << toBin(i) << "];" << "\n";
		cout << "#50" << "\n";
		cout << "assign" << i << " = " << "douta;\n";
	}

	return 0;
}