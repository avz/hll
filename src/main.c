#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include "hll.h"

int main(int argc, const char *argv[]) {
	struct HLL hll;
	char line[16*1024];
	ssize_t size = 0;
	ssize_t r, i, last;

	hll_init(&hll, 15);

	while((r = read(STDIN_FILENO, line + size, sizeof(line) - (size_t)size))) {
		if(r == -1) {
			perror("read");
			exit((errno & 0xff) ? errno & 0xff : 1);
		}

		last = 0;

		for(i = size; i < size + r; i++) {
			if(line[i] == '\n') {
				hll_add(&hll, line + last, (size_t)(i - last));
				last = i + 1;
			}
		}

		size += r;

		if(last < size) {
			memmove(line, line + last, size - last);
			size = size - last;
		} else {
			size = 0;
		}

		if(size == sizeof(line)) {
			fprintf(stderr, "%s: line is too long, ignore\n", argv[0]);
			size = 0;
		}
	}

	if(size) {
		hll_add(&hll, line, (size_t)size);
	}

	printf("%llu\n", (unsigned long long)hll_count(&hll));

	return 0;
}
