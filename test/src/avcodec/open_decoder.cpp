#include "../simple_logger.h"
#include "../../avpp/avcodec/avcodec.h"
#include "../../avpp/avcodec/codec.h"
#include "../../avpp/avutil/dict.h"

using namespace avpp;

int main(int argc, char** argv)
{
	try {
		simple_logger_init();
		if (argc < 2) {
			Log::error("expected at least one argument");
			return -1;
		}
		AVCodecPtr codec = avcodec_find_decoder_by_name(argv[1]);
		if (codec == nullptr) {
			Log::error("decoder {} not found", argv[1]);
			return -1;
		}
		Log::debug("decoder {} found", argv[1]);
		auto context = codec_alloc_context(*codec);
		if (!context) {
			Log::error("failed to allocated codec context");
			return -1;
		}
		AVDictionaryPtr options = nullptr;
		if (argc >= 3) {
			options = dict_parse_string(argv[2], "=", ",");
			if (!options) {
				Log::error("failed to parse options {}", argv[2]);
				return -1;
			}
			Log::debug("options {} parsed", argv[2]);
		}
		auto dict = options.release();
		auto ret = avcodec_open2(context.get(), codec, &dict);
		options.reset(dict);
		if (ret < 0) {
			Log::error("failed to open codec {}", argv[1]);
			return -1;
		}
		Log::info("opened codec {}", argv[1]);
		return 0;
	}
	catch (std::exception& e) {
		Log::fatal(e.what());
		return -1;
	}
}