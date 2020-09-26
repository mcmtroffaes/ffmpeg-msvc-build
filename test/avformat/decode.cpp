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
		spdlog::info("found codec {}", codec->name);
		context = codec_alloc_context(*codec);
		if (!context) {
			spdlog::critical("failed to allocate codec context");
			throw std::runtime_error("failed to allocate codec context");
		}
		int ret = avcodec_parameters_to_context(context.get(), &par);
		if (ret < 0) {
			spdlog::critical("failed to copy codec parameters to codec context");
			throw std::runtime_error("failed to copy codec parameters to codec context");
		}
		auto dict = options.release();
		ret = avcodec_open2(context.get(), codec, &dict);
		options.reset(dict);
		if (ret < 0) {
			spdlog::critical("failed to open codec");
			throw std::runtime_error("failed to open codec");
		}
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
			spdlog::error("cannot handle packet media type {}", av_get_media_type_string(context->codec->type));
			return -1;
		}
	}

	int decode_audio_video_packet(const AVPacket& pkt)
	{
		int ret = 0;
		// submit the packet to the decoder
		ret = avcodec_send_packet(context.get(), &pkt);
		if (ret < 0) {
			spdlog::error("error submitting a packet for decoding: {}", av_error_string(ret));
			return -1;
		}
		// get all the available frames from the decoder
		while (ret >= 0) {
			auto frame = frame_alloc();
			if (!frame) {
				spdlog::critical("failed to allocate frame");
				throw std::runtime_error("failed to allocate frame");
			}
			ret = avcodec_receive_frame(context.get(), frame.get());
			if (ret < 0) {
				// those two return values are special and mean there is no output
				// frame available, but there were no errors during decoding
				if (ret == AVERROR_EOF || ret == AVERROR(EAGAIN))
					return 0;
				spdlog::error("error during decoding: {}", av_error_string(ret));
				return -1;
			}
			if (context->codec->type == AVMEDIA_TYPE_VIDEO) {
				spdlog::debug("frame dimensions: {}x{}", frame->width, frame->height);
				auto desc = av_pix_fmt_desc_get((AVPixelFormat)frame->format);
				spdlog::debug("frame pixel format: {}", desc->name);
			}
			else if (context->codec->type == AVMEDIA_TYPE_AUDIO) {
				spdlog::debug("frame samples: {}", frame->nb_samples);
				spdlog::debug("frame sample format: {}", av_get_sample_fmt_name((AVSampleFormat)frame->format));
			}
			else {
				spdlog::error("cannot handle codec type {}", context->codec->type);
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
			spdlog::error("failed to decode subtitle: {}", av_error_string(ret));
			return -1;
		}
		else {
			spdlog::debug("start display time: {}", sub.start_display_time);
			spdlog::debug("end display time: {}", sub.end_display_time);
			spdlog::debug("num rects: {}", sub.num_rects);
			for (unsigned int i = 0; i < sub.num_rects; i++) {
				spdlog::debug("rect {}", i);
				spdlog::debug("  type: {}", sub.rects[i]->type);
				if (sub.rects[i]->text)
					spdlog::debug("  text: {}", sub.rects[i]->text);
				if (sub.rects[i]->ass)
					spdlog::debug("  ass: {}", sub.rects[i]->ass);
			}
			avsubtitle_free(&sub);
		}
		return 0;
	}
};


int main(int argc, char** argv)
{
	if (argc < 2) {
		spdlog::error("expected at least one argument");
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
	spdlog::info("input format: {}", fmt_ctx->iformat->name);
	std::vector<Stream> streams;
	spdlog::info("number of streams: {}", fmt_ctx->nb_streams);
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
		spdlog::info("packet stream index: {}", pkt.stream_index);
		int ret = streams[pkt.stream_index].decode_packet(pkt);
		av_packet_unref(&pkt);
		if (ret < 0)
			return -1;
		nb_packets++;
	}
	if (nb_packets == 0) {
		spdlog::error("no packets decoded, something must be wrong");
		return -1;
	}
	return 0;
}