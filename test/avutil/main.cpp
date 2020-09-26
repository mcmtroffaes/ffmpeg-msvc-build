#include <stdio.h>
#include <spdlog/spdlog.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/avutil.h>
}

int main()
{
    spdlog::info(av_version_info());
    spdlog::info("avutil version {}", avutil_version());
    spdlog::info(avutil_configuration());
    spdlog::info(avutil_license());
    return 0;
}