module api.core.loggers.builtins.base_logger;

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

abstract class BaseLogger
{
    protected
    {
        LogLevel _level = LogLevel.all;
    }

    bool isForLevel(LogLevel mustBeLevel)
    {
        return mustBeLevel <= _level;
    }

    LogLevel level() => _level;
    void level(LogLevel newLavel)
    {
        _level = newLavel;
    }
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
