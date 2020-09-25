#include <iostream>
#include <vector>
#include "format.h"

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/pixdesc.h>
}

struct Stream {
	AVCodecContextPtr context;
	Stream(const AVCodecParameters& par, AVDictionaryPtr& options)
		: context{ nullptr }
	{
		auto codec = find_decoder(par.codec_id);
		if (!codec)
			throw std::invalid_argument("decoder not found");
		std::cout << "found codec " << codec->name << std::endl;
		context = codec_alloc_context(*codec);
		if (!context)
			throw std::runtime_error("failed to allocated codec");
		int ret = avcodec_parameters_to_context(context.get(), &par);
		if (ret < 0)
			throw std::runtime_error("failed to copy codec parameters to decoder context");
		auto dict = options.release();
		ret = avcodec_open2(context.get(), codec, &dict);
		options.reset(dict);
		if (ret < 0)
			throw std::runtime_error("failed to open codec");
	}

	int decode_packet(AVPacket& pkt) {
		switch (context->codec->type) {
		case AVMEDIA_TYPE_AUDIO:
		case AVMEDIA_TYPE_VIDEO:
			return decode_audio_video_packet(pkt);
			break;
		case AVMEDIA_TYPE_SUBTITLE:
			return decode_subtitle_packet(pkt);
			break;
		default:
			std::cerr << "unhandled packet type " << context->codec->type << std::endl;
			return -1;
		}
	}

	int decode_audio_video_packet(const AVPacket& pkt)
	{
		int ret = 0;
		// submit the packet to the decoder
		ret = avcodec_send_packet(context.get(), &pkt);
		if (ret < 0) {
			std::cerr << "error submitting a packet for decoding: " << av_error_string(ret) << std::endl;
			return -1;
		}
		// get all the available frames from the decoder
		while (ret >= 0) {
			auto frame = frame_alloc();
			if (!frame)
				throw std::runtime_error("failed to allocate frame");
			ret = avcodec_receive_frame(context.get(), frame.get());
			if (ret < 0) {
				// those two return values are special and mean there is no output
				// frame available, but there were no errors during decoding
				if (ret == AVERROR_EOF || ret == AVERROR(EAGAIN))
					return 0;
				std::cerr << "error during decoding: " << av_error_string(ret) << std::endl;
				return -1;
			}
			if (context->codec->type == AVMEDIA_TYPE_VIDEO) {
				std::cout << "frame dimensions: " << frame->width << "x" << frame->height << std::endl;
				auto desc = av_pix_fmt_desc_get((AVPixelFormat)frame->format);
				std::cout << "frame pixel format: " << desc->name << std::endl;
			}
			else if (context->codec->type == AVMEDIA_TYPE_AUDIO) {
				std::cout << "frame samples: " << frame->nb_samples << std::endl;
				std::cout << "frame sample format: " << av_get_sample_fmt_name((AVSampleFormat)frame->format) << std::endl;
			}
			else {
				std::cerr << "cannot handle codec type" << std::endl;
				return -1;
			}
			av_frame_unref(frame.get());
		}
		return 0;
	}

	int decode_subtitle_packet(AVPacket& pkt) {
		AVSubtitle sub;
		int sub_decoded = 0;
		int ret = avcodec_decode_subtitle2(context.get(), &sub, &sub_decoded, &pkt);
		if (ret < 0 || !sub_decoded) {
			std::cerr << "failed to decode subtitle: " << av_error_string(ret) << std::endl;
			return -1;
		}
		else {
			std::cout << "start display time: " << sub.start_display_time << std::endl;
			std::cout << "end display time: " << sub.end_display_time << std::endl;
			std::cout << "num rects: " << sub.num_rects << std::endl;
			for (unsigned int i = 0; i < sub.num_rects; i++) {
				std::cout << "rect " << i << std::endl;
				std::cout << "  type: " << sub.rects[i]->type << std::endl;
				if (sub.rects[i]->text)
					std::cout << "  text: " << sub.rects[i]->text << std::endl;
				if (sub.rects[i]->ass)
					std::cout << "  ass: " << sub.rects[i]->ass << std::endl;
			}
			avsubtitle_free(&sub);
		}
		return 0;
	}
};


int main(int argc, char** argv)
{
	if (argc < 2) {
		std::cerr << "expected at least one argument" << std::endl;
		return -1;
	}
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	auto fmt_ctx = open_input(argv[1]);
	if (!fmt_ctx)
		return -1;
	AVDictionaryPtr options = nullptr;
	if (argc >= 3) {
		options = dict_parse_string(argv[2], "=", ",");
	}
	std::cout << "input format: " << fmt_ctx->iformat->name << std::endl;
	std::vector<Stream> streams;
	std::cout << "number of streams: " << fmt_ctx->nb_streams << std::endl;
	for (unsigned int i = 0; i < fmt_ctx->nb_streams; i++) {
		if (!fmt_ctx->streams[i])
			throw std::runtime_error("stream is null");
		if (!fmt_ctx->streams[i]->codecpar)
			throw std::runtime_error("codecpar is null");
		streams.emplace_back(*fmt_ctx->streams[i]->codecpar, options);
	}
	AVPacket pkt = { 0 };
	av_init_packet(&pkt);
	int nb_packets = 0;
	while (av_read_frame(fmt_ctx.get(), &pkt) >= 0) {
		std::cout << "packet stream index: " << pkt.stream_index << std::endl;
		int ret = streams[pkt.stream_index].decode_packet(pkt);
		av_packet_unref(&pkt);
		if (ret < 0)
			return -1;
		nb_packets++;
	}
	if (nb_packets == 0) {
		std::cerr << "no packets decoded, something must be wrong" << std::endl;
		return -1;
	}
	return 0;
}