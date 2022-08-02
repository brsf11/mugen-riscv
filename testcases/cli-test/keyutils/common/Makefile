targets = $(shell ls | grep -vE "Makefile|*.c")

all:
	gcc -lkeyutils t_request_key.c -o test_key
clean:
	rm -f $(targets)

