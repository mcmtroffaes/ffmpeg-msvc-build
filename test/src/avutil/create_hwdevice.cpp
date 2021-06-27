#include "../logger.h"

extern "C" {
#include <libavutil/hwcontext.h>
}

using namespace avpp;

int main(int argc, char** argv)
{
	logger_init();
	if (argc != 2) {
		Log::error("expected one argument");
		return -1;
	}
	auto hwdevice_type{ av_hwdevice_find_type_by_name(argv[1]) };
	if (hwdevice_type == AV_HWDEVICE_TYPE_NONE) {
		Log::error("hwdevice type {} not found", argv[1]);
		return -1;
	}
	Log::info("hwdevice type {} found", argv[1]);
	AVBufferRef* buffer_ref{ nullptr };
	int err = 0;
	if (av_hwdevice_ctx_create(&buffer_ref, hwdevice_type, nullptr, nullptr, 0) < 0) {
		Log::error("hwdevice type {} not created", argv[1]);
		return -1;
	}
	Log::info("hwdevice type {} created", argv[1]);
	av_buffer_unref(&buffer_ref);
	return 0;
}