#include "codec.h"

int main(int argc, char** argv)
{
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	spdlog::set_level(spdlog::level::debug);
	if (argc < 2) {
		spdlog::error("expected at least one argument");
		return -1;
	}
	AVCodecPtr codec = avcodec_find_decoder_by_name(argv[1]);
	if (codec == nullptr) {
		spdlog::error("decoder {} not found", argv[1]);
		return -1;
	}
	spdlog::debug("encoder {} found", argv[1]);
	auto context = codec_alloc_context(*codec);
	if (!context) {
		spdlog::error("failed to allocated codec context");
		return -1;
	}
	AVDictionaryPtr options = nullptr;
	if (argc >= 3) {
		options = dict_parse_string(argv[2], "=", ",");
		if (!options) {
			spdlog::error("failed to parse options {}", argv[2]);
			return -1;
		}
		spdlog::debug("options {} parsed", argv[2]);
	}
	auto dict = options.release();
	auto ret = avcodec_open2(context.get(), codec, &dict);
	options.reset(dict);
	if (ret < 0) {
		spdlog::error("failed to open codec {}", argv[1]);
		return -1;
	}
	spdlog::info("opened codec {}", argv[1]);
	return 0;
}