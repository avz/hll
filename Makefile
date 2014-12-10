CC=cc
LD=$(CC)

PROJECT=hll

OBJS=main.o hll.o MurmurHash3.o
VPATH=src

CFLAGS?=-O2

build: $(PROJECT)

$(PROJECT): $(OBJS)
	$(LD) -lc $(LDFLAGS) $(OBJS) -o "$(PROJECT)"

.c.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 $(CFLAGS) src/$*.c

MurmurHash3.o:
	$(CC) -c -g $(CFLAGS) deps/MurmurHash3/MurmurHash3.c

clean:
	rm -f *.o "$(PROJECT)"
