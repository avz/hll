CC=cc
LD=$(CC)

PROJECT=hll

OBJS=main.o hll.o murmurhash.o
VPATH=src

CFLAGS?=-O2

build: $(PROJECT)

$(PROJECT): $(OBJS)
	$(LD) -lc $(LDFLAGS) $(OBJS) -o "$(PROJECT)"

.c.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 $(CFLAGS) src/$*.c

murmurhash.o:
	$(CC) -c -g $(CFLAGS) deps/murmurhash/murmurhash.c

clean:
	rm -f *.o "$(PROJECT)"
