#pragma once

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/avcodec.h>
}

#include <memory>
#include "../avutil/log.h"

using namespace avpp;

struct AVCodecContextDeleter {
	void operator()(AVCodecContext* context) const {
		avcodec_free_context(&context);
	};
};

struct AVFrameDeleter {
	void operator()(AVFrame* frame) const {
		av_frame_free(&frame);
	};
};

struct AVPacketDeleter {
	void operator()(AVPacket* pkt) const {
		av_packet_free(&pkt);
	};
};

using AVCodecContextPtr = std::unique_ptr<AVCodecContext, AVCodecContextDeleter>;
using AVFramePtr = std::unique_ptr<AVFrame, AVFrameDeleter>;
using AVPacketPtr = std::unique_ptr<AVPacket, AVPacketDeleter>;

AVCodecContextPtr codec_alloc_context(const AVCodec& codec) {
	auto context = avcodec_alloc_context3(&codec);
	if (!context)
		Log::error("failed to allocate context for {} codec", codec.name);
	return AVCodecContextPtr{ context };
}

AVPacketPtr packet_alloc() {
	auto pkt = av_packet_alloc();
	if (!pkt)
		Log::error("failed to allocate packet");
	return AVPacketPtr{ pkt };
}

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
