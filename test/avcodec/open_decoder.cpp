#include <iostream>
#include "codec.h"

int main(int argc, char** argv)
{
	if (argc < 2) {
		std::cerr << "expected at least one argument" << std::endl;
		return -1;
	}
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	AVCodecPtr codec = avcodec_find_decoder_by_name(argv[1]);
	if (codec == nullptr) {
		std::cerr << "decoder " << argv[1] << " not found" << std::endl;
		return -1;
	}
	auto context = codec_alloc_context(*codec);
	if (!context) {
		std::cerr << "failed to allocated codec context" << std::endl;
		return -1;
	}
	AVDictionaryPtr options = nullptr;
	if (argc >= 3) {
		options = dict_parse_string(argv[2], "=", ",");
		if (!options) {
			std::cerr << "failed to parse options " << argv[2] << std::endl;
			return -1;
		}
	}
	auto dict = options.release();
	auto ret = avcodec_open2(context.get(), codec, &dict);
	options.reset(dict);
	if (ret < 0) {
		std::cerr << "failed to open codec" << std::endl;
		return -1;
	}
	return 0;
}