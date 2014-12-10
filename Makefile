CC=cc
LD=$(CC)

PROJECT=hll-count

OBJS=main.o hll.o MurmurHash3.o
VPATH=src

CFLAGS?=-O2

build: $(PROJECT)

$(PROJECT): $(OBJS)
	$(LD) -lc $(LDFLAGS) $(OBJS) -o "$(PROJECT)"

.c.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror $(CFLAGS) src/$*.c

MurmurHash3.o:
	$(CC) -c -std=c90 -g -Wall -Wconversion -Werror $(CFLAGS) deps/MurmurHash3/MurmurHash3.c

clean:
	rm -f *.o "$(PROJECT)"
