CC=cc
LD=$(CC)

PROJECT=hll-count

OBJS=hll.o MurmurHash3.o
VPATH=src

CFLAGS?=-O2

build: lib bin

bin: lib main.o
	mkdir -p bin
	$(LD) -lc $(LDFLAGS) -Llib -lhyperloglog main.o -o "bin/$(PROJECT)"

lib: $(OBJS)
	mkdir -p lib
	ar rcs lib/libhyperloglog.a $(OBJS)

.c.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror $(CFLAGS) src/$*.c

MurmurHash3.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror $(CFLAGS) deps/MurmurHash3/MurmurHash3.c

clean:
	rm -f *.o bin/"$(PROJECT)" lib/hll.a
	rm -rf bin lib
