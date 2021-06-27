#pragma once

extern "C" {
#include <libavutil/error.h>
}

#include <string>

namespace avpp {

std::string make_error_string(int errnum) {
	char buffer[AV_ERROR_MAX_STRING_SIZE] = { 0 };
	av_make_error_string(buffer, sizeof(buffer), errnum);
	return std::string(buffer);
}

}