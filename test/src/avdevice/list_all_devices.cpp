#include <iostream>

extern "C" {
#include <libavdevice/avdevice.h>
}

template <typename T>
void list_devices(T*(*func_next)(T*))
{
	T* format = func_next(nullptr);
	while (format) {
		std::cout << format->name << std::endl;
		format = func_next(format);
	};
}

int main()
{
	avdevice_register_all();
	std::cout << "audio input devices:" << std::endl;
	list_devices(av_input_audio_device_next);
	std::cout << "video input devices:" << std::endl;
	list_devices(av_input_video_device_next);
	std::cout << "audio output devices:" << std::endl;
	list_devices(av_output_audio_device_next);
	std::cout << "video output devices:" << std::endl;
	list_devices(av_output_video_device_next);
	return 0;
}