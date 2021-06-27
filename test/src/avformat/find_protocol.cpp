#include "../logger.h"

extern "C" {
#include <libavformat/avformat.h>
}

using namespace avpp;

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
	logger_init();
	if (argc != 3) {
		Log::error("expected two arguments");
		return -1;
	}
	if (argv[1] != std::string("output") && argv[1] != std::string("input")) {
		Log::error("expected \"input\" or \"output\" for first argument");
		return -1;
	}
	if (!find_protocol(argv[2], std::string("output") == argv[1])) {
		Log::error("{} protocol {} not found", argv[1], argv[2]);
		return -1;
	}
	Log::info("{} protocol {} found", argv[1], argv[2]);
	return 0;
}