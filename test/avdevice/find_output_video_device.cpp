#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/avstring.h>
#include <libavdevice/avdevice.h>
}

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
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc != 2) {
		logger::error() << "expected one argument";
		return -1;
	}

	avdevice_register_all();
	if (!find_device(av_output_video_device_next, argv[1])) {
		logger::error() << "output video device " << argv[1] << " not found";
		return -1;
	};
	logger::info() << "output video device " << argv[1] << " found";
	return 0;
}