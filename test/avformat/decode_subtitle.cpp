#include <iostream>
#include "avcreate.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/pixdesc.h>
}

int main(int argc, char** argv)
{
	if (argc != 2) {
		std::cerr << "expected one argument" << std::endl;
		return -1;
	}
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	AVPacket pkt = { 0 };
	auto fmt_ctx = open_input(argv[1]);
	if (!fmt_ctx)
		return -1;
	std::cout << "input format: " << fmt_ctx->iformat->name << std::endl;
	av_init_packet(&pkt);
	int ret = 0;
	if (ret = av_read_frame(fmt_ctx.get(), &pkt) < 0) {
		std::cerr << "failed to read frame: " << av_error_string(ret) << std::endl;
		return -1;
	}
	std::cout << "packet stream index: " << pkt.stream_index << std::endl;
	auto par = fmt_ctx->streams[pkt.stream_index]->codecpar;
	auto codec = find_decoder(par->codec_id);
	if (!codec)
		return -1;
	if (codec->type != AVMEDIA_TYPE_SUBTITLE) {
		std::cerr << "packet does not contain subtitle" << std::endl;
		return -1;
	}
	auto codec_ctx = codec_alloc_context(*codec);
	if (!codec_ctx)
		return -1;
	ret = avcodec_parameters_to_context(codec_ctx.get(), par);
	if (ret < 0) {
		std::cerr << "failed to copy codec parameters to decoder context" << std::endl;
		return -1;
	}
	if ((ret = avcodec_open2(codec_ctx.get(), codec, nullptr)) < 0) {
		std::cerr << "failed to open codec " << codec->name << std::endl;
		return -1;
	}
	AVSubtitle sub;
	int sub_decoded;
	int ret2 = avcodec_decode_subtitle2(codec_ctx.get(), &sub, &sub_decoded, &pkt);
	if (ret2 < 0 || !sub_decoded) {
		std::cerr << "failed to decode frame: " << av_error_string(ret2) << std::endl;
		return -1;
	}
	else {
		std::cout << "start display time: " << sub.start_display_time << std::endl;
		std::cout << "end display time: " << sub.end_display_time << std::endl;
		std::cout << "num rects: " << sub.num_rects << std::endl;
		for (int i = 0; i < sub.num_rects; i++) {
			std::cout << "rect " << i << std::endl;
			std::cout << "  type: " << sub.rects[i]->type << std::endl;
			if (sub.rects[i]->text)
				std::cout << "  text: " << sub.rects[i]->text << std::endl;
			if (sub.rects[i]->ass)
				std::cout << "  ass: " << sub.rects[i]->ass << std::endl;
		}
		avsubtitle_free(&sub);
	}
	av_packet_unref(&pkt);
	return 0;
}