#pragma once

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/avcodec.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

struct AVCodecContextDeleter {
	void operator()(AVCodecContext* context) const {
		avcodec_free_context(&context);
	};
};

using AVCodecContextPtr = std::unique_ptr<AVCodecContext, AVCodecContextDeleter>;

AVCodecContextPtr codec_alloc_context(const AVCodec& codec) {
	auto context = avcodec_alloc_context3(&codec);
	if (!context)
		Log::error("failed to allocate context for {} codec", codec.name);
	return AVCodecContextPtr{ context };
}

}