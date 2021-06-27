#include "../logger.h"

extern "C" {
#include <libavdevice/avdevice.h>
}

using namespace avpp;

int main()
{
    logger_init();
    Log::info("avdevice version {}", avdevice_version());
    Log::info(avdevice_configuration());
    Log::info(avdevice_license());
    return 0;
}