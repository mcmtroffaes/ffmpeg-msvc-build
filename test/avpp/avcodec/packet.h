#pragma once

extern "C" {
#include <libavcodec/packet.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

struct AVPacketDeleter {
	void operator()(AVPacket* pkt) const {
		AVPP_TRACE_ENTER;
		av_packet_free(&pkt);
		AVPP_TRACE_EXIT;
	};
};

using AVPacketPtr = std::unique_ptr<AVPacket, AVPacketDeleter>;

AVPacketPtr packet_alloc() {
	AVPP_TRACE_ENTER;
	auto pkt = av_packet_alloc();
	if (!pkt)
		Log::error("failed to allocate packet");
	AVPP_TRACE_RETURN(AVPacketPtr{ pkt });
}

}