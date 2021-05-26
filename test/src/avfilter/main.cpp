#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavfilter/avfilter.h>
}

int main()
{
    logger::info() << "avfilter version " << avfilter_version();
    logger::info() << avfilter_configuration();
    logger::info() << avfilter_license();
    return 0;
}