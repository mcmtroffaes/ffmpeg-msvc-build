#include "codec.h"

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	if (argc < 2) {
		logger::error() << "expected at least one argument";
		return -1;
	}
	AVCodecPtr codec = avcodec_find_decoder_by_name(argv[1]);
	if (codec == nullptr) {
		logger::error() << "decoder " << argv[1] << " not found";
		return -1;
	}
	logger::debug() << "decoder " << argv[1] << " found";
	auto context = codec_alloc_context(*codec);
	if (!context) {
		logger::error() << "failed to allocated codec context";
		return -1;
	}
	AVDictionaryPtr options = nullptr;
	if (argc >= 3) {
		options = dict_parse_string(argv[2], "=", ",");
		if (!options) {
			logger::error() << "failed to parse options " << argv[2];
			return -1;
		}
		logger::debug() << "options " << argv[2] << " parsed";
	}
	auto dict = options.release();
	auto ret = avcodec_open2(context.get(), codec, &dict);
	options.reset(dict);
	if (ret < 0) {
		logger::error() << "failed to open codec " << argv[1];
		return -1;
	}
	logger::info() << "opened codec " << argv[1];
	return 0;
}