#pragma once

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavcodec/packet.h>
}

#include <memory>
#include "../avutil/log.h"

namespace avpp {

struct AVPacketDeleter {
	void operator()(AVPacket* pkt) const {
		av_packet_free(&pkt);
	};
};

using AVPacketPtr = std::unique_ptr<AVPacket, AVPacketDeleter>;

AVPacketPtr packet_alloc() {
	auto pkt = av_packet_alloc();
	if (!pkt)
		Log::error("failed to allocate packet");
	return AVPacketPtr{ pkt };
}

}