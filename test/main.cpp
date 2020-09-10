// main.cpp
#include <stdio.h>
#include <stdexcept>

extern "C" {
#include <libavcodec/avcodec.h>
}

int main()
{
    printf("%i.%i.%i\n", LIBAVCODEC_VERSION_MAJOR, LIBAVCODEC_VERSION_MINOR, LIBAVCODEC_VERSION_MICRO);
    const AVCodec* codec = avcodec_find_encoder(AV_CODEC_ID_VP9);
    if (!codec) {
        throw(std::runtime_error("codec vp9 not found"));
    }
    getchar();
    return 0;
}