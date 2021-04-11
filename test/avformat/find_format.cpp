#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
}

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc != 3) {
		logger::error() << "expected two arguments";
		return -1;
	}
	if (argv[1] == std::string("input")) {
		if (!av_find_input_format(argv[2])) {
			logger::error() << "input format " << argv[2] << " not found";
			return -1;
		}
		logger::info() << "input format " << argv[2] << " found";
	}
	else if (argv[1] == std::string("output")) {
		if (!av_guess_format(argv[2], nullptr, nullptr)) {
			logger::error() << "output format " << argv[2] << " not found";
			return -1;
		}
		logger::info() << "output format " << argv[2] << " found";
	}
	else {
		logger::error() << "expected \"input\" or \"output\" for first argument";
		return -1;
	}
	return 0;
}