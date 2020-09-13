// main.cpp
#include <iostream>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/avcodec.h>
}

auto media_type_str(AVMediaType t) {
	switch (t) {
	case AVMEDIA_TYPE_UNKNOWN: return "unknown";
	case AVMEDIA_TYPE_VIDEO: return "video";
	case AVMEDIA_TYPE_AUDIO: return "audio";
	case AVMEDIA_TYPE_DATA: return "data";
	case AVMEDIA_TYPE_SUBTITLE: return "subtitle";
	case AVMEDIA_TYPE_ATTACHMENT: return "attachment";
	default: return "invalid";
	}
}

int main()
{
	AVCodec* p = nullptr;
	void* i = nullptr;
	while ((p = (AVCodec*)av_codec_iterate(&i))) {
		std::cout
			<< "name:    " << p->name << std::endl
			<< "type:    " << media_type_str(p->type) << std::endl
			<< "encoder: " << av_codec_is_encoder(p) << std::endl
			<< "decoder: " << av_codec_is_decoder(p) << std::endl
			<< std::endl;
	}
	return 0;
}