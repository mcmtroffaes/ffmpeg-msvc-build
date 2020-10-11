#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <avresample/avresample.h>
}

int main()
{
    logger::info() << "avresample version " << avresample_version();
    logger::info() << avresample_configuration();
    logger::info() << avresample_license();
    return 0;
}