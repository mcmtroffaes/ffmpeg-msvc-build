#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
}

bool find_protocol(std::string name, int output)
{
	void* opaque = nullptr;
	const char* proto_name = nullptr;
	while ((proto_name = avio_enum_protocols(&opaque, output))) {
		if (name == proto_name) return true;
	};
	return false;
}

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc != 3) {
		logger::error() << "expected two arguments";
		return -1;
	}
	if (argv[1] != std::string("output") && argv[1] != std::string("input")) {
		logger::error() << "expected \"input\" or \"output\" for first argument";
		return -1;
	}
	if (!find_protocol(argv[2], std::string("output") == argv[1])) {
		logger::error() << argv[1] << " protocol " << argv[2] << " not found";
		return -1;
	}
	logger::info() << argv[1] << " protocol " << argv[2] << " found";
	return 0;
}