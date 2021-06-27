#pragma once

extern "C" {
#include <libavcodec/avcodec.h>
}

#include <memory>
#include "../avutil/log.h"
#include "../avutil/dict.h"
#include "../avcodec/codec.h"

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

int codec_open(AVCodecContext& context, const AVCodec& codec, AVDictionaryPtr& options) {
	AVPP_TRACE_ENTER;
	auto dict = options.release();
	int ret = avcodec_open2(&context, &codec, &dict);
	options.reset(dict);
	AVPP_TRACE_RETURN(ret);
}

}