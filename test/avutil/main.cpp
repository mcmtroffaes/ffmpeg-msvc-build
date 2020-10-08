#include <stdio.h>
#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/avutil.h>
}

int main()
{
    logger::info() << av_version_info();
    logger::info() << "avutil version" << avutil_version();
    logger::info() << avutil_configuration();
    logger::info() << avutil_license();
    return 0;
}