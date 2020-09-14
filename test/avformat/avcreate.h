#pragma once

#include <iostream>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
#include <libavutil/error.h>
#include <libavutil/log.h>
}

std::string av_error_string(int errnum) {
	char buffer[AV_ERROR_MAX_STRING_SIZE] = { 0 };
	av_make_error_string(buffer, sizeof(buffer), errnum);
	return std::string(buffer);
}

struct AVFormatContextDeleter {
	void operator()(AVFormatContext* context) const {
		avformat_close_input(&context);
	};
};

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

using AVFormatContextPtr = std::unique_ptr<AVFormatContext, AVFormatContextDeleter>;
using AVCodecPtr = const AVCodec*;
using AVCodecContextPtr = std::unique_ptr<AVCodecContext, AVCodecContextDeleter>;
using AVFramePtr = std::unique_ptr<AVFrame, AVFrameDeleter>;

AVFormatContextPtr open_input(const std::string& url) {
	AVFormatContext* context{ nullptr };
	auto ret{ avformat_open_input(&context, url.c_str(), nullptr, nullptr) };
	if (ret < 0) {
		std::cerr << "failed to allocate output context for " << url << ": " << av_error_string(ret) << std::endl;
	}
	else if (!context) {
		std::cerr << "failed to allocate output context for " << url << std::endl;
	}
	else {
		auto ret2{ avformat_find_stream_info(context, 0) };
		if (ret2 < 0) {
			std::cerr << "failed to retrieve input stream information for " << url << ": " << av_error_string(ret) << std::endl;
			avformat_close_input(&context);
			context = nullptr;
		}
	}
	return AVFormatContextPtr{ context };
}

AVCodecPtr find_decoder(const AVCodecID& codec_id) {
	auto codec = avcodec_find_decoder(codec_id);
	if (!codec)
		std::cerr << "failed find decoder with id " << codec_id << std::endl;
	return codec;
}

AVCodecContextPtr codec_alloc_context(const AVCodec& codec) {
	auto context = avcodec_alloc_context3(&codec);
	if (!context)
		std::cerr << "failed to allocate context for " << codec.name << " codec" << std::endl;
	return AVCodecContextPtr{ context };
}

AVFramePtr frame_alloc() {
	auto frame = av_frame_alloc();
	if (!frame) {
		std::cerr << "failed to allocate frame" << std::endl;
	}
	else {
		frame->pts = 0;
	}
	return AVFramePtr{ frame };
}
