#include "../logger.h"
#include <stdio.h>

extern "C" {
#include <libavutil/avutil.h>
}

using namespace avpp;

int main()
{
    logger_init();
    Log::info(av_version_info());
    Log::info("avutil version {}", avutil_version());
    Log::info(avutil_configuration());
    Log::info(avutil_license());
    return 0;
}