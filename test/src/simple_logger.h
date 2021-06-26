#pragma once

#include "../avpp/avutil/log.h"
#include <iostream>

class SimpleLogger : public avpp::Logger
{
public:
    virtual void log(int level, std::string msg) {
        std::cerr << "[" << avpp::log_get_level_str(level) << "] " << msg << std::endl;
    }
};

#define LOG_ENTER avpp::Log::trace("{}: enter", __FUNCTION__);
#define LOG_EXIT avpp::Log::trace("{}: exit", __FUNCTION__);

void simple_logger_init() {
    avpp::Log::register_logger(std::make_shared<SimpleLogger>());
    av_log_set_level(AV_LOG_DEBUG);
    av_log_set_flags(0);
    LOG_ENTER;
    av_log_set_callback(avpp::log_default_callback);
    LOG_EXIT;
}
