#include "../simple_logger.h"
#include <stdio.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/avutil.h>
}

using namespace avpp;

int main()
{
    simple_logger_init();
    Log::info(av_version_info());
    Log::info("avutil version {}", avutil_version());
    Log::info(avutil_configuration());
    Log::info(avutil_license());
    return 0;
}