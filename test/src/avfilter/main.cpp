#include "../logger.h"

extern "C" {
#include <libavfilter/avfilter.h>
}

using namespace avpp;

int main()
{
    logger_init();
    Log::info("avfilter version {}", avfilter_version());
    Log::info(avfilter_configuration());
    Log::info(avfilter_license());
    return 0;
}