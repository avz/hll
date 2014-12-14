/*
 * File: examples/rnd.c
 */

#include <stdio.h>
#include <stdlib.h>
#include "../src/hll.h"

int main(int argc, char *argv[]) {
	long i;
	struct HLL hll;

	if(hll_init(&hll, 16) == -1) {
		perror("hll_init");
		exit(1);
	}

	for(i = 0; i < 100000000; i++) {
		long r = random() % 1000000;

		hll_add(&hll, &r, sizeof(r));
	}

	printf("Estimate: %f\n", hll_count(&hll));

	hll_destroy(&hll);

	return 0;
}
