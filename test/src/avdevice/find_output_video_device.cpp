#include "../simple_logger.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/avstring.h>
#include <libavdevice/avdevice.h>
}

using namespace avpp;

template <typename T>
bool find_device(T*(*func_next)(T*), const char* name)
{
	T* format = nullptr;
	while (format = func_next(format)) {
		if (av_match_name(name, format->name)) return true;
	};
	return false;
}

int main(int argc, char** argv)
{
	simple_logger_init();
	if (argc != 2) {
		Log::error("expected one argument");
		return -1;
	}

	avdevice_register_all();
	if (!find_device(av_output_video_device_next, argv[1])) {
		Log::error("output video device {} not found", argv[1]);
		return -1;
	};
	Log::info("output video device {} found", argv[1]);
	return 0;
}