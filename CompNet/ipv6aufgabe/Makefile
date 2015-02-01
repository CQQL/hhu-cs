CFLAGS=-std=c99 -Wall -Werror -fstack-protector-all -D_POSIX_SOURCE

all: hl_server hl_client

hl_client: hl_client.c hl_common.c hl_common.h
	gcc ${CFLAGS} hl_client.c hl_common.c -o hl_client

hl_server: hl_server.c hl_common.c hl_common.h
	gcc ${CFLAGS} hl_server.c hl_common.c -o hl_server

clean:
	rm -f hl_client hl_server

.PHONY: all clean
