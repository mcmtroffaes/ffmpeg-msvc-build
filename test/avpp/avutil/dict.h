#pragma once

extern "C" {
#include <libavutil/dict.h>
}

#include <memory>
#include <string>
#include "log.h"

namespace avpp {

struct AVDictionaryDeleter {
	void operator()(AVDictionary* dict) const {
		AVPP_TRACE_ENTER;
		av_dict_free(&dict);
		AVPP_TRACE_EXIT;
	};
};

using AVDictionaryPtr = std::unique_ptr<AVDictionary, AVDictionaryDeleter>;

AVDictionaryPtr dict_parse_string(const std::string& options, const std::string& key_val_sep, const std::string& pairs_sep)
{
	AVPP_TRACE_ENTER;
	AVDictionary* dict{};
	auto ret = av_dict_parse_string(&dict, options.c_str(), key_val_sep.c_str(), pairs_sep.c_str(), 0);
	if (ret < 0)
		Log::error("failed to parse dictionary");
	AVPP_TRACE_RETURN(AVDictionaryPtr{ dict });
}

}