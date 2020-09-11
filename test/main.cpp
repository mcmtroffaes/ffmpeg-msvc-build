// main.cpp
#include <stdio.h>

extern "C" {
#include <libavutil/avutil.h>
}

int main()
{
    printf("%i\n", avutil_version());
    return 0;
}