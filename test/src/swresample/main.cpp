#include "../simple_logger.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libswresample/swresample.h>
}

using namespace avpp;

int main()
{
    simple_logger_init();
    Log::info("swresample version {}", swresample_version());
    Log::info(swresample_configuration());
    Log::info(swresample_license());
    return 0;
}