#include <spdlog/spdlog.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libpostproc/postprocess.h>
}

int main()
{
    spdlog::info("postproc version {}", postproc_version());
    spdlog::info(postproc_configuration());
    spdlog::info(postproc_license());
    return 0;
}