#include "stdio.h"
#include "stdlib.h"

#define DEF_VAR_1 DEF_VAR_2 10
#ifndef IFNDEF_VAR
#define IFNDEF_VAR DEF_VAR_1
#endif

#if (DEF_VAR_2 > 0)
#define IF_VAR DEF_VAR_2+10
#endif

int main(int argc, char** argv){
    printf("This is 1st autoconf_test file.")
    return 0;
}