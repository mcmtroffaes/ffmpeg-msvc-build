#include <spdlog/spdlog.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libswresample/swresample.h>
}

int main()
{
    spdlog::info("swresample version {}", swresample_version());
    spdlog::info(swresample_configuration());
    spdlog::info(swresample_license());
    return 0;
}