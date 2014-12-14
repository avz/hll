#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include "hll.h"

static double count_stdin(uint8_t bits);
void usage(const char *cmd);

int main(int argc, char * const argv[]) {
	uint8_t bits = 16;
	double estimate;
	int ch;
	unsigned long b;

	while((ch = getopt(argc, argv, "b:")) != -1) {
		switch(ch) {
			case 'b':
				b = strtoul(optarg, NULL, 10);
				if(b == ULONG_MAX || b < 4 || b > 20) {
					usage(argv[0]);
				}

				bits = (uint8_t)b;
			break;
			case '?':
			default:
				usage(argv[0]);
		}
	}

	estimate = count_stdin(bits);

	printf("%.0f\n", estimate);

	return 0;
}

void usage(const char *cmd) {
	fprintf(stderr, "Usage: %s [-b bits]\n", cmd);
	fprintf(stderr, "	-b bits: set registers count = 2^bits [default 16]\n");
	exit(255);
}

static double count_stdin(uint8_t bits) {
	struct HLL hll;
	double count;
	char line[16*1024];
	ssize_t size = 0;
	ssize_t r, i, last;

	if(hll_init(&hll, bits) == -1) {
		perror("hll_init");
		exit((errno & 0xff) ? errno & 0xff : 1);
	}

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
			memmove(line, line + last, (size_t)(size - last));
			size = size - last;
		} else {
			size = 0;
		}

		if(size == sizeof(line)) {
			fprintf(stderr, "hll-count: line is too long, ignore\n");
			size = 0;
		}
	}

	if(size) {
		hll_add(&hll, line, (size_t)size);
	}

	count = hll_count(&hll);

	hll_destroy(&hll);

	return count;
}
