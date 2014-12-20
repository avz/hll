HyperLogLog library for C language
===
![Build status](https://travis-ci.org/avz/hll.svg?branch=master)

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

|bits|size (bytes) | standard error  |
|----|---------|--------|
|  4 |      16 | 26.00% |
|  5 |      32 | 18.38% |
|  6 |      64 | 13.00% |
|  7 |     128 |  9.19% |
|  8 |     256 |  6.50% |
|  9 |     512 |  4.60% |
| 10 |    1024 |  3.25% |
| 11 |    2048 |  2.30% |
| 12 |    4096 |  1.62% |
| 13 |    8192 |  1.15% |
| 14 |   16384 |  0.81% |
| 15 |   32768 |  0.57% |
| 16 |   65536 |  0.41% |
| 17 |  131072 |  0.29% |
| 18 |  262144 |  0.20% |
| 19 |  524288 |  0.14% |
| 20 | 1048576 |  0.10% |

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

Merge storages
```c
int hll_merge(struct HLL *dst, const struct HLL *src);
```

Cleanup
```c
void hll_destroy(struct HLL *hll);
```

TODO
==

оптимизировать размер хранилища: при `bits >= 4 && bits <= 16` достаточно
5 бит на регистр, вместо нынешних 8, получим экономию в 1.5+ раза. Для
`bits >= 17 && bits <= 20` достаточно всего 4 бит на регистр, то есть
экономия в 2 раза.

|bits|regs count|bpr| bytes | saving | error  |
|----|---------|---|--------|--------|--------|
|  4 |      16 | 5 |     10 | 37.50% | 26.00% |
|  5 |      32 | 5 |     20 | 37.50% | 18.38% |
|  6 |      64 | 5 |     40 | 37.50% | 13.00% |
|  7 |     128 | 5 |     80 | 37.50% |  9.19% |
|  8 |     256 | 5 |    160 | 37.50% |  6.50% |
|  9 |     512 | 5 |    320 | 37.50% |  4.60% |
| 10 |    1024 | 5 |    640 | 37.50% |  3.25% |
| 11 |    2048 | 5 |   1280 | 37.50% |  2.30% |
| 12 |    4096 | 5 |   2560 | 37.50% |  1.62% |
| 13 |    8192 | 5 |   5120 | 37.50% |  1.15% |
| 14 |   16384 | 5 |  10240 | 37.50% |  0.81% |
| 15 |   32768 | 5 |  20480 | 37.50% |  0.57% |
| 16 |   65536 | 5 |  40960 | 37.50% |  0.41% |
| 17 |  131072 | 4 |  65536 | 50.00% |  0.29% |
| 18 |  262144 | 4 | 131072 | 50.00% |  0.20% |
| 19 |  524288 | 4 | 262144 | 50.00% |  0.14% |
| 20 | 1048576 | 4 | 524288 | 50.00% |  0.10% |
