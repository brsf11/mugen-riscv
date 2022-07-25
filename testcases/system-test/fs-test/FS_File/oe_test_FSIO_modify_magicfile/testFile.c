#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<string.h>
#include<stdio.h>
#include<unistd.h>
#include<errno.h>

#define FLAGS O_WRONLY | O_CREAT | O_TRUNC
#define MODE S_IRWXU | S_IXGRP | S_IROTH | S_IXOTH

int main(void)
{
    int count = 0;
    const char* filename;
    int fd;
    char name[1000];
    scanf("%s", name);
    filename = name;
    while(1){
        if ((fd = open(filename, FLAGS, MODE)) == -1) {
                break;
        }
        write(fd,name,strlen(name));
        count++;
    }

    printf("%d", count);
    return 0;
}

