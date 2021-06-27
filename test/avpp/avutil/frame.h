#pragma once

extern "C" {
#include <libavutil/frame.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

struct AVFrameDeleter {
	void operator()(AVFrame* frame) const {
		AVPP_TRACE_ENTER;
		av_frame_free(&frame);
		AVPP_TRACE_EXIT;
	};
};

using AVFramePtr = std::unique_ptr<AVFrame, AVFrameDeleter>;

AVFramePtr frame_alloc() {
	AVPP_TRACE_ENTER;
	auto frame = av_frame_alloc();
	if (!frame) {
		Log::error("failed to allocate frame");
	}
	else {
		frame->pts = 0;
	}
	AVPP_TRACE_RETURN(AVFramePtr{ frame });
}

}