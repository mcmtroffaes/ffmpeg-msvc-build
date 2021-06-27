#include <iostream>

extern "C" {
#include <libavformat/avformat.h>
}

template <typename T>
void list_formats(T* (*func_next)(void**))
{
	void* opaque = nullptr;
	while (T* format = func_next(&opaque)) {
		std::cout << format->name << std::endl;
	};
}

int main()
{
	std::cout << "input formats:" << std::endl;
	list_formats(av_demuxer_iterate);
	std::cout << "output formats:" << std::endl;
	list_formats(av_muxer_iterate);
	return 0;
}