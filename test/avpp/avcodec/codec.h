#pragma once

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/codec.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

using AVCodecPtr = const AVCodec*;

AVCodecPtr find_decoder(const AVCodecID& codec_id) {
	auto codec = avcodec_find_decoder(codec_id);
	if (!codec)
		Log::error("failed find decoder with id {}", codec_id);
	return codec;
}

}