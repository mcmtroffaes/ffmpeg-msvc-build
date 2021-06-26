#include "../simple_logger.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavdevice/avdevice.h>
}

using namespace avpp;

int main()
{
    simple_logger_init();
    Log::info("avdevice version {}", avdevice_version());
    Log::info(avdevice_configuration());
    Log::info(avdevice_license());
    return 0;
}