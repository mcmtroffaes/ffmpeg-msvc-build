#pragma once

#include <memory>
#include <spdlog/spdlog.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/avcodec.h>
#include <libavutil/error.h>
#include <libavutil/log.h>
}

std::string av_error_string(int errnum) {
	char buffer[AV_ERROR_MAX_STRING_SIZE] = { 0 };
	av_make_error_string(buffer, sizeof(buffer), errnum);
	return std::string(buffer);
}

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

struct AVDictionaryDeleter {
	void operator()(AVDictionary* dict) const {
		av_dict_free(&dict);
	};
};

using AVCodecPtr = const AVCodec*;
using AVCodecContextPtr = std::unique_ptr<AVCodecContext, AVCodecContextDeleter>;
using AVFramePtr = std::unique_ptr<AVFrame, AVFrameDeleter>;
using AVDictionaryPtr = std::unique_ptr<AVDictionary, AVDictionaryDeleter>;

AVCodecPtr find_decoder(const AVCodecID& codec_id) {
	auto codec = avcodec_find_decoder(codec_id);
	if (!codec)
		spdlog::error("failed find decoder with id {}", codec_id);
	return codec;
}

AVCodecContextPtr codec_alloc_context(const AVCodec& codec) {
	auto context = avcodec_alloc_context3(&codec);
	if (!context)
		spdlog::error("failed to allocate context for {} codec", codec.name);
	return AVCodecContextPtr{ context };
}

AVFramePtr frame_alloc() {
	auto frame = av_frame_alloc();
	if (!frame) {
		spdlog::error("failed to allocate frame");
	}
	else {
		frame->pts = 0;
	}
	return AVFramePtr{ frame };
}

AVDictionaryPtr dict_parse_string(const std::string& options, const std::string& key_val_sep, const std::string& pairs_sep)
{
	AVDictionary* dict{};
	auto ret = av_dict_parse_string(&dict, options.c_str(), key_val_sep.c_str(), pairs_sep.c_str(), 0);
	if (ret < 0)
		spdlog::error("failed to parse dictionary");
	return AVDictionaryPtr{ dict };
}
