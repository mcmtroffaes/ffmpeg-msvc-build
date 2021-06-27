#pragma once

extern "C" {
#include <libavcodec/packet.h>
}

#include <memory>
#include <stdexcept>
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
		throw std::runtime_error("failed to allocate packet");
	return AVPacketPtr{ pkt };
}

}