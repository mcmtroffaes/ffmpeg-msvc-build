#include "../simple_logger.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libpostproc/postprocess.h>
}

using namespace avpp;

int main()
{
    simple_logger_init();
    Log::info("postproc version {}", postproc_version());
    Log::info(postproc_configuration());
    Log::info(postproc_license());
    return 0;
}