CC?=cc
LD=$(CC)

PROJECT=hll

OBJS=hll.o MurmurHash3.o
VPATH=src

CFLAGS?=-O2

build: bin/hll-count

bin/hll-count: lib/libhyperloglog.a main.o
	mkdir -p bin
	$(LD) -lm -lc $(LDFLAGS) -Llib main.o -lhyperloglog -o bin/hll-count

lib/libhyperloglog.a: $(OBJS)
	mkdir -p lib
	ar rcs lib/libhyperloglog.a $(OBJS)

.c.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror $(CFLAGS) src/$*.c

MurmurHash3.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror $(CFLAGS) deps/MurmurHash3/MurmurHash3.c

clean:
	rm -f *.o bin/hll-count lib/hll.a
	rm -rf bin lib

test:
	sh ./tests/hll-count.sh
