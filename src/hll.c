#include <stdlib.h>
#include <errno.h>
#include <math.h>

#include <stdio.h>

#include "../deps/murmurhash/murmurhash.h"
#include "hll.h"

static inline unsigned char _hll_rank(uint32_t hash, uint8_t bits) {
	uint8_t i;

	for(i = 1; i <= 32 - bits; i++) {
		if(hash & 1)
			break;

		hash >>= 1;
	}

	return i;
}

int hll_init(struct HLL *hll, uint8_t bits) {
	if(bits < 4 || bits > 20) {
		errno = ERANGE;
		return -1;
	}

	hll->bits = bits;
	hll->size = 1 << bits;
	hll->registers = calloc(hll->size, 1);

	return 0;
}

void hll_destroy(struct HLL *hll) {
	free(hll->registers);

	hll->registers = NULL;
}

void hll_add(struct HLL *hll, const void *buf, size_t len) {
	uint32_t hash = murmurhash((const char *)buf, (uint32_t)len, 0x5f61767a);

	hll_add_hash(hll, hash);
}

void hll_add_hash(struct HLL *hll, uint32_t hash) {
	uint32_t index = hash >> (32 - hll->bits);
	uint8_t rank = _hll_rank(hash, hll->bits);

	if(rank > hll->registers[index]) {
		hll->registers[index] = rank;
	}
}

double hll_count(const struct HLL *hll) {
	double alpha_mm;
	switch (hll->bits) {
		case 4:
			alpha_mm = 0.673;
		break;
		case 5:
			alpha_mm = 0.697;
		break;
		case 6:
			alpha_mm = 0.709;
		break;
		default:
			alpha_mm = 0.7213 / (1.0 + 1.079 / hll->size);
		break;
	}

	alpha_mm *= (hll->size * hll->size);

	double sum = 0;
	for(int i = 0; i < hll->size; i++) {
		sum += 1.0 / (1 << hll->registers[i]);
	}

	double estimate = alpha_mm / sum;

	if (estimate <= 5.0 / 2.0 * hll->size) {
		int zeros = 0;

		for(int i = 0; i < hll->size; i++)
			zeros += (hll->registers[i] == 0);

		if(zeros)
			estimate = hll->size * log((double)hll->size / zeros);

	} else if (estimate > (1.0 / 30.0) * 4294967296.0) {
		estimate = -4294967296.0 * log(1.0 - (estimate / 4294967296.0));
	}

	return estimate;
}
