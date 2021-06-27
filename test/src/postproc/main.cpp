#include "../logger.h"

extern "C" {
#include <libpostproc/postprocess.h>
}

using namespace avpp;

int main()
{
    logger_init();
    Log::info("postproc version {}", postproc_version());
    Log::info(postproc_configuration());
    Log::info(postproc_license());
    return 0;
}