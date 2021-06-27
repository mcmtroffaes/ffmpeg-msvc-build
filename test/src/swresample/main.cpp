#include "../logger.h"

extern "C" {
#include <libswresample/swresample.h>
}

using namespace avpp;

int main()
{
    logger_init();
    Log::info("swresample version {}", swresample_version());
    Log::info(swresample_configuration());
    Log::info(swresample_license());
    return 0;
}