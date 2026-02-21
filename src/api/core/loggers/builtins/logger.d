module api.core.loggers.builtins.logger;

import api.core.loggers.builtins.base_logger : BaseLogger;
import api.core.loggers.builtins.base_logger : LogLevel, levelToStr;
import api.core.loggers.builtins.handlers.base_log_handler : BaseLogHandler;

import core.sync.mutex : Mutex;

/**
 * Authors: initkfs
 */
class Logger : BaseLogger
{
    protected
    {
        BaseLogHandler[] handlers;

        shared Mutex _mutex;
    }

    this(LogLevel level = LogLevel.all) @safe
    {
        _level = level;
        _mutex = new shared Mutex;
    }

    void add(BaseLogHandler handler)
    {
        handlers ~= handler;
    }

    protected void writeLog(LogLevel level, const(char)[] msg, string file, ulong line)
    {
        import std.format : format;

        import Mem = api.core.utils.mem;

        auto memSize = Mem.memBytes;

        import std.datetime.systime : Clock;
        auto timestamp = Clock.currTime.toUTC;
        string timestampStr = timestamp.toSimpleString;

        import api.core.utils.time: utcTimeBuff;

        char[64] buffer = void;
        auto res = utcTimeBuff(buffer[], "%Y-%m-%d %H:%M:%S");
        char[] timeStr = (res > 0 && res < buffer.length) ? buffer[0 .. res] : null;

        auto result = format("%s [%s] %s:%d %s [%s]",
            timeStr,
            levelToStr(level),
            file,
            line,
            msg, Mem.formatBytes(memSize));

        foreach (h; handlers)
        {
            h.output(level, result);
        }
    }

    void log(LogLevel level, const(char)[] msg, string file, ulong line)
    {
        synchronized (_mutex)
        {
            if (!isForLevel(level))
            {
                return;
            }

            writeLog(level, msg, file, line);
        }
    }

    void log(const(char)[] message, string file = __FILE__, size_t line = __LINE__)
    {
        log(_level, message, file, line);
    }

    void trace(const(char)[] message, string file = __FILE__, size_t line = __LINE__)
    {
        log(LogLevel.trace, message, file, line);
    }

    void info(const(char)[] message, string file = __FILE__, size_t line = __LINE__)
    {
        log(LogLevel.info, message, file, line);
    }

    void warning(const(char)[] message, string file = __FILE__, size_t line = __LINE__)
    {
        log(LogLevel.warning, message, file, line);
    }

    void error(const(char)[] message, string file = __FILE__, size_t line = __LINE__)
    {
        log(LogLevel.error, message, file, line);
    }

    void logf(string file, size_t line, Args...)(LogLevel level, const(char)[] formatMsg, Args args)
    {
        synchronized (_mutex)
        {
            if (!isForLevel(level))
            {
                return;
            }

            import std.format : format;

            auto result = format(formatMsg, args);
            writeLog(level, result, file, line);
        }

    }

    void tracef(string file = __FILE__, size_t line = __LINE__, Args...)(Args args)
    {
        logf!(file, line)(LogLevel.trace, args);
    }

    void infof(string file = __FILE__, size_t line = __LINE__, Args...)(Args args)
    {
        logf!(file, line)(LogLevel.info, args);
    }

    void warningf(string file = __FILE__, size_t line = __LINE__, Args...)(Args args)
    {
        logf!(file, line)(LogLevel.warning, args);
    }

    void errorf(string file = __FILE__, size_t line = __LINE__, Args...)(Args args)
    {
        logf!(file, line)(LogLevel.error, args);
    }
}

unittest
{

}
