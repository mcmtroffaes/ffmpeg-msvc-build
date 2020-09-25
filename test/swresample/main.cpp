#include <spdlog/spdlog.h>

extern "C" {
#define __STDC_CONSTANT_MACROS
#include <libavutil/log.h>
#include <libavutil/opt.h>
#include <libavutil/channel_layout.h>
#include <libavutil/samplefmt.h>
#include <libswresample/swresample.h>
}

int main(int argc, char** argv)
{
    if (argc != 2) {
        spdlog::error("expected one argument");
        return -1;
    }
    av_log_set_callback(av_log_default_callback);
    av_log_set_level(AV_LOG_DEBUG);
    SwrEngine engine{ SWR_ENGINE_NB };
    if (std::string("swr").compare(argv[1]) == 0) {
        engine = SWR_ENGINE_SWR;
    }
    else if (std::string("soxr").compare(argv[1]) == 0) {
        engine = SWR_ENGINE_SOXR;
    }
    else {
        spdlog::error("expected swr or soxr as first argument");
        return -1;
    }
    struct SwrContext* swr_ctx;
    swr_ctx = swr_alloc();
    if (!swr_ctx) {
        spdlog::error("could not allocate resampler context");
        return -1;
    }
    av_opt_set_int(swr_ctx, "in_channel_layout", AV_CH_LAYOUT_STEREO, 0);
    av_opt_set_int(swr_ctx, "in_sample_rate", 48000, 0);
    av_opt_set_sample_fmt(swr_ctx, "in_sample_fmt", AV_SAMPLE_FMT_U8, 0);
    av_opt_set_int(swr_ctx, "out_channel_layout", AV_CH_LAYOUT_STEREO, 0);
    av_opt_set_int(swr_ctx, "out_sample_rate", 44100, 0);
    av_opt_set_sample_fmt(swr_ctx, "out_sample_fmt", AV_SAMPLE_FMT_U8, 0);
    av_opt_set_int(swr_ctx, "resampler", engine, 0);
    if (swr_init(swr_ctx) < 0) {
        spdlog::error("could not initialize resampler context");
        swr_free(&swr_ctx);
        return -1;
    }
    swr_free(&swr_ctx);
    return 0;
}