#pragma once

extern "C" {
#include <libavcodec/codec.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

using AVCodecPtr = const AVCodec*;

AVCodecPtr codec_find_decoder(AVCodecID codec_id) {
	auto codec = avcodec_find_decoder(codec_id);
	if (!codec)
		Log::error("failed to find decoder with id {}", codec_id);
	return codec;
}

}