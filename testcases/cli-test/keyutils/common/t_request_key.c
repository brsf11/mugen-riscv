/* t_request_key.c */
  
#include <sys/types.h>
#include <keyutils.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    key_serial_t key;

    if (argc != 4) {
        fprintf(stderr, "Usage: %s type description callout-data\n",
                argv[0]);
        exit(EXIT_FAILURE);
    }

    key = request_key(argv[1], argv[2], argv[3],
                      KEY_SPEC_SESSION_KEYRING);
    if (key == -1) {
        perror("request_key");
        exit(EXIT_FAILURE);
    }

    printf("Key ID is %lx\n", (long) key);

    exit(EXIT_SUCCESS);
}

