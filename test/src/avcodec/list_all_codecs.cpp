#include <iostream>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/avcodec.h>
}

int main()
{
	const AVCodec* p = nullptr;
	void* i = nullptr;
	while ((p = av_codec_iterate(&i))) {
		std::cout
			<< "name:    " << p->name << std::endl
			<< "type:    " << av_get_media_type_string(p->type) << std::endl
			<< "encoder: " << av_codec_is_encoder(p) << std::endl
			<< "decoder: " << av_codec_is_decoder(p) << std::endl
			<< std::endl;
	}
	return 0;
}