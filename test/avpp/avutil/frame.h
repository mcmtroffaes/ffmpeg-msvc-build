#pragma once

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/frame.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

struct AVFrameDeleter {
	void operator()(AVFrame* frame) const {
		av_frame_free(&frame);
	};
};

using AVFramePtr = std::unique_ptr<AVFrame, AVFrameDeleter>;

AVFramePtr frame_alloc() {
	auto frame = av_frame_alloc();
	if (!frame) {
		Log::error("failed to allocate frame");
	}
	else {
		frame->pts = 0;
	}
	return AVFramePtr{ frame };
}

}