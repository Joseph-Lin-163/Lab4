#include <iostream>
#include <stdlib.h>

using namespace std;

int main() {
	cout << "memory_initialization_radix=2;\nmemory_initialization_vector=\n";
	for (int i = 0; i < 8; i++) {
		for (int j = 0; j < 350; j++) {
			cout << rand() % 2;
		}
		cout << ",\n";
	}
}