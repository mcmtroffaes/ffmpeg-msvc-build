#pragma once

extern "C" {
#include <libavformat/avformat.h>
}

#include <memory>
#include "../avutil/error.h"
#include "../avutil/log.h"

namespace avpp {

struct AVFormatContextDeleter {
	void operator()(AVFormatContext* context) const {
		AVPP_TRACE_ENTER;
		avformat_close_input(&context);
		AVPP_TRACE_EXIT;
	};
};

using AVFormatContextPtr = std::unique_ptr<AVFormatContext, AVFormatContextDeleter>;

AVFormatContextPtr open_input(std::string url, std::string format_name) {
	AVPP_TRACE_ENTER;
	AVFormatContext* context{ nullptr };
	auto input_format{ av_find_input_format(format_name.c_str()) };
	if (!input_format) {
		Log::error("failed to find input format {}", format_name);
		return nullptr;
	}
	auto ret{ avformat_open_input(&context, url.c_str(), input_format, nullptr) };
	if (ret < 0) {
		Log::error("failed to allocate output context for {}: {}", url, make_error_string(ret));
	}
	else if (!context) {
		Log::error("failed to allocate output context for {}", url);
	}
	else {
		auto ret2{ avformat_find_stream_info(context, nullptr) };
		if (ret2 < 0) {
			Log::error("failed to retrieve input stream information for {}: {}", url, make_error_string(ret));
			avformat_close_input(&context);
			context = nullptr;
		}
	}
	AVPP_TRACE_RETURN(AVFormatContextPtr{ context });
}

}