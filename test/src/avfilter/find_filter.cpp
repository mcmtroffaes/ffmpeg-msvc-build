#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavfilter/avfilter.h>
#include <libavutil/log.h>
}

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc != 2) {
		logger::error() << "expected one argument";
		return -1;
	}
	if (avfilter_get_by_name(argv[1]) == nullptr) {
		logger::error() << "filter " << argv[1] << " not found";
		return -1;
	}
	logger::info() << "filter " << argv[1] << " found";
	return 0;
}