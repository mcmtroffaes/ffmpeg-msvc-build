#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libpostproc/postprocess.h>
}

int main()
{
    logger::info() << "postproc version " << postproc_version();
    logger::info() << postproc_configuration();
    logger::info() << postproc_license();
    return 0;
}