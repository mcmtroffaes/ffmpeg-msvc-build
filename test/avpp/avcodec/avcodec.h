#pragma once

extern "C" {
#include <libavcodec/avcodec.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

struct AVCodecContextDeleter {
	void operator()(AVCodecContext* context) const {
		AVPP_TRACE_ENTER;
		avcodec_free_context(&context);
		AVPP_TRACE_EXIT;
	};
};

using AVCodecContextPtr = std::unique_ptr<AVCodecContext, AVCodecContextDeleter>;

AVCodecContextPtr codec_alloc_context(const AVCodec& codec) {
	AVPP_TRACE_ENTER;
	auto context = avcodec_alloc_context3(&codec);
	if (!context)
		Log::error("failed to allocate context for {} codec", codec.name);
	AVPP_TRACE_RETURN(AVCodecContextPtr{ context });
}

}