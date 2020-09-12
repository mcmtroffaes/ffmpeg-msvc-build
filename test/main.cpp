// main.cpp
#include <stdio.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/avutil.h>
}

int main()
{
    printf("%i\n", avutil_version());
    return 0;
}