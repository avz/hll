HyperLogLog library for C programming language
===

See http://en.wikipedia.org/wiki/HyperLogLog

Example
==

```c
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
```
```
% cc -O2 -L lib -l hyperloglog examples/rnd.c -o examples/rnd
% time examples/rnd
Estimate: 994154.464585
examples/rnd  2,86s user 0,01s system 99% cpu 2,875 total
```


API
==
```c
struct HLL {
	uint8_t bits;

	/* registers buffer */
	uint8_t *registers;

	/* registers buffer size */
	size_t size;
};
```

Initialize a storage
```c
int hll_init(struct HLL *hll, uint8_t bits);
```

Add key to set
```c
void hll_add(struct HLL *hll, const void *buf, size_t size);
```

Get estimated set size
```c
double hll_count(const struct HLL *hll);
```

Cleanup
```c
void hll_destroy(struct HLL *hll);
```
