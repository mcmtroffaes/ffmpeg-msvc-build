#pragma once

#include <fmt/format.h>
#include <memory>
#include <string>

extern "C" {
#include <libavutil/log.h>
}

/* implements a C++ style logger to which we hook the ffmpeg logger via a callback */

namespace avpp {

// Abstract base class for logging. Clients should subclass this to intercept log messages.
class Logger
{
public:
	virtual void log(int level, std::string msg) = 0;
	virtual ~Logger() {};
};

// Class for encapsulating all logging functions that operate on a logger.
class Log
{
private:
	inline static std::shared_ptr<Logger>& _logger()
	{
		// Using static variable in function to emulate global static variable in header-only library.
		// https://stackoverflow.com/a/51612943/2863746
		static std::shared_ptr<Logger> logger = nullptr;
		return logger;
	}
public:
    static void register_logger(std::shared_ptr<Logger> logger)
    {
        _logger() = logger;
    }

    template <typename ...Args>
    static void log(int level, Args && ...args) {
        if (_logger() && level <= av_log_get_level())
			_logger()->log(level, fmt::format(std::forward<Args>(args)...));
    }

	template <typename ...Args>
	static void panic(Args && ...args) {
		log(AV_LOG_PANIC, std::forward<Args>(args)...);
	}

	template <typename ...Args>
    static void fatal(Args && ...args) {
        log(AV_LOG_FATAL, std::forward<Args>(args)...);
    }

    template <typename ...Args>
    static void error(Args && ...args) {
        log(AV_LOG_ERROR, std::forward<Args>(args)...);
    }

	template <typename ...Args>
	static void warning(Args && ...args) {
		log(AV_LOG_WARNING, std::forward<Args>(args)...);
	}

	template <typename ...Args>
	static void info(Args && ...args) {
		log(AV_LOG_INFO, std::forward<Args>(args)...);
	}

	template <typename ...Args>
	static void verbose(Args && ...args) {
		log(AV_LOG_VERBOSE, std::forward<Args>(args)...);
	}

	template <typename ...Args>
	static void debug(Args && ...args) {
		log(AV_LOG_DEBUG, std::forward<Args>(args)...);
	}

	template <typename ...Args>
	static void trace(Args && ...args) {
		log(AV_LOG_TRACE, std::forward<Args>(args)...);
	}
};

// Callback that can be with av_log_set_callback, forwarding all log messages to Log::log.
void log_default_callback(void* avcl, int level, const char* fmt, va_list vl)
{
	// each thread should have its own character buffer
	thread_local char line[256] = { 0 };
	thread_local int pos = 0;
	thread_local int print_prefix = 1;

	int remain = sizeof(line) - pos;
	if (remain > 0) {
		int ret = av_log_format_line2(avcl, level, fmt, vl, line + pos, remain, &print_prefix);
		if (ret >= 0) {
			pos += (ret <= remain) ? ret : remain;
		}
		else {
			// log at the specified level rather than error level to avoid spamming the log
			Log::log(level, "failed to format av_log message: {}", fmt);
		}
	}
	// only write log message on newline
	size_t i = strnlen(fmt, sizeof(line));
	if ((i > 0) && (fmt[i - 1] == '\n')) {
		// remove newline (assume logger adds a newline automatically)
		if ((pos > 0) && (line[pos - 1] == '\n')) {
			line[pos - 1] = '\0';
		}
		Log::log(level, line);
		pos = 0;
		*line = '\0';
	}
}

const char* log_get_level_str(int level)
{
	switch (level) {
	case AV_LOG_QUIET:
		return "quiet";
	case AV_LOG_TRACE:
		return "trace";
	case AV_LOG_DEBUG:
		return "debug";
	case AV_LOG_VERBOSE:
		return "verbose";
	case AV_LOG_INFO:
		return "info";
	case AV_LOG_WARNING:
		return "warning";
	case AV_LOG_ERROR:
		return "error";
	case AV_LOG_FATAL:
		return "fatal";
	case AV_LOG_PANIC:
		return "panic";
	default:
		return "";
	}
}

} // namespace avpp
