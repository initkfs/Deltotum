module api.core.loggers.slogger.logger_level;

/**
 * Authors: initkfs
 */

enum LogLevel : ubyte
{
    off,
    error,
    warning,
    info,
    trace,
    all
}

string levelToStr(LogLevel v)
{
    final switch (v) with (LogLevel)
    {
        case off:
            return "off";
        case error:
            return "error";
        case warning:
            return "warning";
        case info:
            return "info";
        case trace:
            return "trace";
        case all:
            return "all";
    }

}
