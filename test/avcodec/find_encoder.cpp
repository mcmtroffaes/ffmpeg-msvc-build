// main.cpp
#include <iostream>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/avcodec.h>
#include <libavutil/log.h>
}

int main(int argc, char** argv)
{
	if (argc != 2) {
		std::cout << "expected one argument" << std::endl;
		return -1;
	}
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (avcodec_find_encoder_by_name(argv[1]) == nullptr) {
		std::cout << "encoder " << argv[1] << " not found" << std::endl;
		return -1;
	}
	return 0;
}