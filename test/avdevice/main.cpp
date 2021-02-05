#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavdevice/avdevice.h>
}

int main()
{
    logger::info() << "avdevice version " << avdevice_version();
    logger::info() << avdevice_configuration();
    logger::info() << avdevice_license();
    return 0;
}