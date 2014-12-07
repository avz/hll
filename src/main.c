#include <stdlib.h>
#include <stdio.h>
#include "hll.h"

int main(int argc, const char *argv[]) {
	struct HLL hll;

	hll_init(&hll, 15);

	srandomdev();
	long salt = random();

	for(uint32_t i = 0; i < 10000000; i++) {
		uint32_t r = (uint32_t)salt + i;

		hll_add(&hll, &r, 4);
	}

	printf("%f\n", hll_count(&hll));
	hll_destroy(&hll);

	return 0;
}
