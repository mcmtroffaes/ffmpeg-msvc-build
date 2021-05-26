#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libswresample/swresample.h>
}

int main()
{
    logger::info() << "swresample version " << swresample_version();
    logger::info() << swresample_configuration();
    logger::info() << swresample_license();
    return 0;
}