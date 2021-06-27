#include "../simple_logger.h"

extern "C" {
#include <libavfilter/avfilter.h>
#include <libavutil/log.h>
}

using namespace avpp;

int main(int argc, char** argv)
{
	simple_logger_init();
	if (argc != 2) {
		Log::error("expected one argument");
		return -1;
	}
	if (avfilter_get_by_name(argv[1]) == nullptr) {
		Log::error("filter {} not found", argv[1]);
		return -1;
	}
	Log::info("filter {} found", argv[1]);
	return 0;
}