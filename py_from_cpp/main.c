#include <iostream>
#include <stdlib.h>

int main() {
	printf("calling py...\n");
	//string paylod = "{\"device_id\" : \"123\"}"
	system("python py.py \"{\\\"device_id\\\" : \\\"123\\\"}\"");

	return 0;
}