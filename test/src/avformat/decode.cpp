#include "../../avpp/avutil/dict.h"
#include "../../avpp/avutil/frame.h"
#include "../../avpp/avcodec/avcodec.h"
#include "../../avpp/avcodec/codec.h"
#include "../../avpp/avcodec/packet.h"
#include "../../avpp/avformat/avformat.h"
#include "../logger.h"

#include <vector>

extern "C" {
#include <libavutil/pixdesc.h>
}

using namespace avpp;

struct Stream {
	AVCodecContextPtr context;
	Stream(const AVCodecParameters& par, AVDictionaryPtr& options)
		: context{ nullptr }
	{
		AVPP_TRACE_ENTER;
		auto codec = codec_find_decoder(par.codec_id);
		if (!codec)
			throw std::invalid_argument("decoder not found");
		Log::info("found codec {}", codec->name);
		context = codec_alloc_context(*codec);
		if (!context) {
			Log::fatal("failed to allocate codec context");
			throw std::runtime_error("failed to allocate codec context");
		}
		int ret = avcodec_parameters_to_context(context.get(), &par);
		if (ret < 0) {
			Log::fatal("failed to copy codec parameters to codec context");
			throw std::runtime_error("failed to copy codec parameters to codec context");
		}
		auto dict = options.release();
		ret = avcodec_open2(context.get(), codec, &dict);
		options.reset(dict);
		if (ret < 0) {
			Log::fatal("failed to open codec");
			throw std::runtime_error("failed to open codec");
		}
		AVPP_TRACE_EXIT;
	}

	int decode_packet(AVPacket& pkt) {
		AVPP_TRACE_ENTER;
		int ret = -1;
		switch (context->codec->type) {
		case AVMEDIA_TYPE_AUDIO:
		case AVMEDIA_TYPE_VIDEO:
			ret = decode_audio_video_packet(pkt);
			AVPP_TRACE_RETURN(ret);
		case AVMEDIA_TYPE_SUBTITLE:
			ret = decode_subtitle_packet(pkt);
			AVPP_TRACE_RETURN(ret);
		default:
			Log::error("cannot handle packet media type {}", av_get_media_type_string(context->codec->type));
			AVPP_TRACE_RETURN(-1);
		}
	}

	int decode_audio_video_packet(const AVPacket& pkt)
	{
		AVPP_TRACE_ENTER;
		int ret = 0;
		// submit the packet to the decoder
		ret = avcodec_send_packet(context.get(), &pkt);
		if (ret < 0) {
			Log::error("error submitting a packet for decoding: {}", make_error_string(ret));
			AVPP_TRACE_RETURN(-1);
		}
		// get all the available frames from the decoder
		while (ret >= 0) {
			auto frame = frame_alloc();
			if (!frame) {
				Log::fatal("failed to allocate frame");
				throw std::runtime_error("failed to allocate frame");
			}
			ret = avcodec_receive_frame(context.get(), frame.get());
			if (ret < 0) {
				// those two return values are special and mean there is no output
				// frame available, but there were no errors during decoding
				if (ret == AVERROR_EOF || ret == AVERROR(EAGAIN))
					return 0;
				Log::error("error during decoding: {}", make_error_string(ret));
				AVPP_TRACE_RETURN(-1);
			}
			if (context->codec->type == AVMEDIA_TYPE_VIDEO) {
				Log::debug("frame dimensions: {}x{}", frame->width ,frame->height);
				auto desc = av_pix_fmt_desc_get((AVPixelFormat)frame->format);
				Log::debug("frame pixel format: {}", desc->name);
			}
			else if (context->codec->type == AVMEDIA_TYPE_AUDIO) {
				Log::debug("frame samples: {}", frame->nb_samples);
				Log::debug("frame sample format: {}", av_get_sample_fmt_name((AVSampleFormat)frame->format));
			}
			else {
				Log::error("cannot handle codec type {}", av_get_media_type_string(context->codec->type));
				AVPP_TRACE_RETURN(-1);
			}
			av_frame_unref(frame.get());
		}
		AVPP_TRACE_RETURN(0);
	}

	int decode_subtitle_packet(AVPacket& pkt) {
		AVPP_TRACE_ENTER;
		AVSubtitle sub;
		int sub_decoded = 0;
		int ret = avcodec_decode_subtitle2(context.get(), &sub, &sub_decoded, &pkt);
		if (ret < 0 || !sub_decoded) {
			Log::error("failed to decode subtitle: {}", make_error_string(ret));
			AVPP_TRACE_RETURN(-1);
		}
		else {
			Log::debug("start display time: {}", sub.start_display_time);
			Log::debug("end display time: {}", sub.end_display_time);
			Log::debug("num rects: {}", sub.num_rects);
			for (unsigned int i = 0; i < sub.num_rects; i++) {
				Log::debug("rect {}", i);
				Log::debug("  type: {}", sub.rects[i]->type);
				if (sub.rects[i]->text)
					Log::debug("  text: {}", sub.rects[i]->text);
				if (sub.rects[i]->ass)
					Log::debug("  ass: {}", sub.rects[i]->ass);
			}
			avsubtitle_free(&sub);
		}
		AVPP_TRACE_RETURN(0);
	}
};


int main(int argc, char** argv)
{
	logger_init();
	if (argc < 3) {
		Log::error("expected at least two arguments");
		return -1;
	}
	auto fmt_ctx = open_input(argv[1], argv[2]);
	if (!fmt_ctx)
		return -1;
	AVDictionaryPtr options = nullptr;
	if (argc >= 4) {
		options = dict_parse_string(argv[3], "=", ",");
	}
	Log::info("input format: {}", fmt_ctx->iformat->name);
	std::vector<Stream> streams;
	Log::info("number of streams: {}", fmt_ctx->nb_streams);
	for (unsigned int i = 0; i < fmt_ctx->nb_streams; i++) {
		if (!fmt_ctx->streams[i])
			throw std::runtime_error("stream is null");
		if (!fmt_ctx->streams[i]->codecpar)
			throw std::runtime_error("codecpar is null");
		streams.emplace_back(*fmt_ctx->streams[i]->codecpar, options);
	}
	auto pkt = packet_alloc();
	int nb_packets = 0;
	while (av_read_frame(fmt_ctx.get(), pkt.get()) >= 0) {
		Log::info("packet stream index: {}", pkt->stream_index);
		Log::debug("packet size: {}", pkt->size);
		Log::debug("packet duration: {}", pkt->duration);
		Log::debug("packet pos: {}", pkt->pos);
		int ret = streams[pkt->stream_index].decode_packet(*pkt);
		av_packet_unref(pkt.get());
		if (ret < 0)
			return -1;
		nb_packets++;
	}
	if (nb_packets == 0) {
		Log::error("no packets decoded, something must be wrong");
		return -1;
	}
	return 0;
}
