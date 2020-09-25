#include "codec.h"

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	spdlog::set_level(spdlog::level::debug);
	if (argc != 2) {
		spdlog::error("expected one argument");
		return -1;
	}
	if (avcodec_find_encoder_by_name(argv[1]) == nullptr) {
		spdlog::error("encoder {} not found", argv[1]);
		return -1;
	}
	spdlog::info("encoder {} found", argv[1]);
	return 0;
}