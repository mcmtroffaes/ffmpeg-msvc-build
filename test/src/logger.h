#pragma once

#include "../avpp/avutil/log.h"
#include <iostream>

class StdErrLogger : public avpp::Logger
{
public:
    virtual void log(int level, std::string msg) {
        std::cerr << "[" << avpp::log_get_level_str(level) << "] " << msg << std::endl;
    }
};

void logger_init() {
    avpp::Log::register_logger(std::make_shared<StdErrLogger>());
    av_log_set_level(AV_LOG_DEBUG);
    av_log_set_flags(0);
    av_log_set_callback(avpp::log_default_callback);
}
