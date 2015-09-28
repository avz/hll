CC?=cc
LD=$(CC)

PROJECT=hll

OBJS=hll.o MurmurHash3.o
VPATH=src

CFLAGS?=-O2

build: bin/hll-count

bin/hll-count: lib/libhyperloglog.a main.o
	mkdir -p bin
	$(LD) -lc $(LDFLAGS) -Llib main.o -lhyperloglog -lm -o bin/hll-count

lib/libhyperloglog.a: $(OBJS)
	mkdir -p lib
	ar rcs lib/libhyperloglog.a $(OBJS)

hll.o:
	$(CC) -c -fPIC -ansi -g -Wall -Wconversion -Werror $(CFLAGS) src/hll.c

MurmurHash3.o:
	$(CC) -c -fPIC -ansi -g -Wall -Wconversion -Werror $(CFLAGS) deps/MurmurHash3/MurmurHash3.c

clean:
	rm -f *.o bin/hll-count lib/hll.a
	rm -rf bin lib

test: build
	sh ./tests/hll-count.sh
