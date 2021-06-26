#include "../simple_logger.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavfilter/avfilter.h>
}

using namespace avpp;

int main()
{
    simple_logger_init();
    Log::info("avfilter version {}", avfilter_version());
    Log::info(avfilter_configuration());
    Log::info(avfilter_license());
    return 0;
}