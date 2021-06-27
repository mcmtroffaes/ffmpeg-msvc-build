#include "../../avpp/avdevice/avdevice.h"
#include "../logger.h"

using namespace avpp;

int main(int argc, char** argv)
{
	logger_init();
	if (argc != 2) {
		Log::error("expected one argument");
		return -1;
	}

	avdevice_register_all();
	auto format = output_video_device_get_by_name(argv[1]);
	if (format == nullptr) {
		Log::error("output video device {} not found", argv[1]);
		return -1;
	};
	Log::info("output video device {} found", argv[1]);
	return 0;
}