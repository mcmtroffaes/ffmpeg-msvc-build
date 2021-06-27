#pragma once

extern "C" {
#include <libavutil/avstring.h>
#include <libavdevice/avdevice.h>
}

#include "../avutil/log.h"

namespace avpp {

namespace detail {

template <typename T>
T* device_get_by_name(T* (*func_next)(T*), const char* name)
{
	AVPP_TRACE_ENTER;
	T* format = func_next(nullptr);
	while (format) {
		if (av_match_name(name, format->name)) {
			AVPP_TRACE_RETURN(format);
		}
		format = func_next(format);
	};
	AVPP_TRACE_RETURN(nullptr);
}

} // namespace detail

AVInputFormat* input_video_device_get_by_name(const char* name)
{
	return detail::device_get_by_name(av_input_video_device_next, name);
}

AVOutputFormat* output_video_device_get_by_name(const char* name)
{
	return detail::device_get_by_name(av_output_video_device_next, name);
}

} // namespace avpp
