// main.cpp
#include <stdio.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
#include <libavutil/log.h>
}

int main(int argc, char **argv)
{
	if (argc != 2) {
		printf("expected one argument");
		return -1;
	}
	av_log_set_callback(av_log_default_callback);
	av_log_set_level(AV_LOG_DEBUG);
	AVFormatContext *s = NULL;
	AVPacket pkt = {0};
	if (avformat_open_input(&s, argv[1], NULL, NULL) < 0) {
		printf("failed to open input\n");
		avformat_free_context(s);
		return -1;
	}
	av_init_packet(&pkt);
	if (av_read_frame(s, &pkt) < 0) {
		printf("failed to read frame\n");
		avformat_free_context(s);
		return -1;
	}
	avformat_free_context(s);
	return 0;
}