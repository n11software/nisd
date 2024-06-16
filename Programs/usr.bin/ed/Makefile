PROG=ed

CC=gcc
CFLAGS=-O2 -ansi -g

$(PROG): main.o ed.o
	$(CC) -o $@ main.o ed.o $(CFLAGS)

clean:
	rm -rf *.o $(PROG)

.c.o:
	$(CC) $(CFLAGS) -c $*.c

main.o: main.c
ed.o: ed.c
