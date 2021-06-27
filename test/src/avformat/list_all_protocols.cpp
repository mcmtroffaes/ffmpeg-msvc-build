#include <iostream>

extern "C" {
#include <libavformat/avformat.h>
}

int main()
{
	void* opaque = nullptr;
	const char* name;
	std::cout << "input protocols:" << std::endl;
	while ((name = avio_enum_protocols(&opaque, 0))) {
		std::cout << name << std::endl;
	}
	std::cout << "output protocols:" << std::endl;
	while ((name = avio_enum_protocols(&opaque, 1))) {
		std::cout << name << std::endl;
	}
	return 0;
}