#pragma once

#include <iostream>
#include <sstream>
#include <utility>

namespace logger {

class Log
{
public:
    Log(const std::string& level) : os() {
        os << "[" << level << "] ";
    };
    ~Log() {
        os << std::endl;
        std::cerr << os.str();
    };
    Log(const Log&) = delete;
    Log& operator=(const Log&) = delete;

    template<typename T>
    friend Log&& operator<<(Log&& logger, T t);
private:
    std::ostringstream os;
};

template<typename T>
Log&& operator<<(Log&& logger, T t)
{
    logger.os << t;
    return std::move(logger);
}

Log critical() {
    return Log("critical");
}

Log error() {
    return Log("error");
}

Log info() {
    return Log("info");
}

Log debug() {
    return Log("debug");
}

}
