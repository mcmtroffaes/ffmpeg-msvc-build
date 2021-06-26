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
	if (avcodec_find_encoder_by_name(argv[1]) == nullptr) {
		Log::error("encoder {} not found", argv[1]);
		return -1;
	}
	Log::info("encoder {} found", argv[1]);
	return 0;
}