// main.cpp
#include <stdio.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavformat/avformat.h>
}

int main(int argc, char **argv)
{
	if (argc != 2) {
		printf("expected one argument");
		return -1;
	}
	AVFormatContext *s = NULL;
	AVPacket pkt = {0};
	if (avformat_open_input(&s, argv[1], NULL, NULL) < 0) {
		printf("failed to open input\n");
		return -1;
	}
	av_init_packet(&pkt);
	if (av_read_frame(s, &pkt) < 0) {
		printf("failed to read frame\n");
		return -1;
	}
	return 0;
}