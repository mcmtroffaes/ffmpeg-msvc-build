#include "../simple_logger.h"
#include "../../avpp/avcodec/avcodec.h"

using namespace avpp;

int main(int argc, char** argv)
{
	simple_logger_init();
	if (argc != 2) {
		Log::error("expected one argument");
		return -1;
	}
	if (avcodec_find_decoder_by_name(argv[1]) == nullptr) {
		Log::error("decoder {} not found", argv[1]);
		return -1;
	}
	Log::info("decoder {} found", argv[1]);
	return 0;
}