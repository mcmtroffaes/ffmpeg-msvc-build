#include "../simple_logger.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
}

using namespace avpp;

int main(int argc, char** argv)
{
	simple_logger_init();
	if (argc != 3) {
		Log::error("expected two arguments");
		return -1;
	}
	if (argv[1] == std::string("input")) {
		if (!av_find_input_format(argv[2])) {
			Log::error("input format {} not found", argv[2]);
			return -1;
		}
		Log::info("input format {} found", argv[2]);
	}
	else if (argv[1] == std::string("output")) {
		if (!av_guess_format(argv[2], nullptr, nullptr)) {
			Log::error("output format {} not found", argv[2]);
			return -1;
		}
		Log::info("output format {} found", argv[2]);
	}
	else {
		Log::error("expected \"input\" or \"output\" for first argument");
		return -1;
	}
	return 0;
}