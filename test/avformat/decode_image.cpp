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
	if (codec->type != AVMEDIA_TYPE_VIDEO) {
		std::cerr << "packet does not contain video" << std::endl;
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
	auto frame = frame_alloc();
	if (!frame)
		return -1;
	int frame_decoded = 0;
	int ret2 = avcodec_decode_video2(codec_ctx.get(), frame.get(), &frame_decoded, &pkt);
	if (ret2 < 0 || !frame_decoded) {
		std::cerr << "failed to decode frame: " << av_error_string(ret2) << std::endl;
		return -1;
	}
	std::cout << "frame dimensions: " << frame->width << "x" << frame->height << std::endl;
	auto desc = av_pix_fmt_desc_get((AVPixelFormat)frame->format);
	std::cout << "frame pixel format: " << desc->name << std::endl;
	av_packet_unref(&pkt);
	return 0;
}