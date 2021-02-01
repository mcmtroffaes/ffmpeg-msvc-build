#include "../log.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/hwcontext.h>
}

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc != 2) {
		logger::error() << "expected one argument";
		return -1;
	}
	auto hwdevice_type{ av_hwdevice_find_type_by_name(argv[1]) };
	if (hwdevice_type == AV_HWDEVICE_TYPE_NONE) {
		logger::error() << "hwdevice type " << argv[1] << " not found";
		return -1;
	}
	logger::info() << "hwdevice type " << argv[1] << " found";
	AVBufferRef* buffer_ref{ nullptr };
	int err = 0;
	if (av_hwdevice_ctx_create(&buffer_ref, hwdevice_type, nullptr, nullptr, 0) < 0) {
		logger::error() << "hwdevice type " << argv[1] << " not created";
		return -1;
	}
	logger::info() << "hwdevice type " << argv[1] << " created";
	av_buffer_unref(&buffer_ref);
	return 0;
}