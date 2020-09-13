// main.cpp
#include <stdio.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libpostproc/postprocess.h>
}

int main()
{
    printf("%i\n", postproc_version());
    return 0;
}