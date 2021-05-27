#pragma once

#include <memory>

#include "../avcodec/codec.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
}

struct AVFormatContextDeleter {
	void operator()(AVFormatContext* context) const {
		avformat_close_input(&context);
	};
};

using AVFormatContextPtr = std::unique_ptr<AVFormatContext, AVFormatContextDeleter>;

AVFormatContextPtr open_input(const std::string& url, const std::string& format_name) {
	AVFormatContext* context{ nullptr };
	auto input_format{ av_find_input_format(format_name.c_str()) };
	if (!input_format) {
		logger::error() << "failed to find input format " << format_name;
		return nullptr;
	}
	auto ret{ avformat_open_input(&context, url.c_str(), input_format, nullptr) };
	if (ret < 0) {
		logger::error() << "failed to allocate output context for " << url << ": " << av_error_string(ret);
	}
	else if (!context) {
		logger::error() << "failed to allocate output context for " << url;
	}
	else {
		auto ret2{ avformat_find_stream_info(context, 0) };
		if (ret2 < 0) {
			logger::error() << "failed to retrieve input stream information for " << url << ": " << av_error_string(ret);
			avformat_close_input(&context);
			context = nullptr;
		}
	}
	return AVFormatContextPtr{ context };
}