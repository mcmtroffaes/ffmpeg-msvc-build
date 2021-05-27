#include "codec.h"

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc != 2) {
		logger::error() << "expected one argument";
		return -1;
	}
	if (avcodec_find_encoder_by_name(argv[1]) == nullptr) {
		logger::error() << "encoder " << argv[1] << " not found";
		return -1;
	}
	logger::info() << "encoder " << argv[1] << " found";
	return 0;
}