module api.core.loggers.slogger.logger;

import api.core.loggers.slogger.logger_level : LogLevel, levelToStr;

import core.sync.mutex : Mutex;
import std.datetime.systime : Clock;
import std.format : format;
import std.conv : to;

/**
 * Authors: initkfs
 */

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

abstract class BaseLoggerHandler : BaseLogger
{
    abstract
    {
        void output(LogLevel level, const(char)[] message);
    }
}

class ConsoleHandler : BaseLoggerHandler
{
    override void output(LogLevel level, const(char)[] message)
    {
        if (!isForLevel(level))
        {
            return;
        }

        import std.stdio : writeln;

        if (level <= LogLevel.error)
        {
            import std.stdio : stderr;

            stderr.writeln(message);
        }
        else
        {
            writeln(message);
        }
    }
}

class FileHandler : BaseLoggerHandler
{
    import std.stdio : File, writeln;

    protected
    {
        File* _logFile;
        string path;
    }

    bool isFlush = true;

    this(string path)
    {
        this.path = path;
    }

    override void output(LogLevel level, const(char)[] message)
    {
        if (!isForLevel(level))
        {
            return;
        }

        if (!_logFile)
        {
            _logFile = new File(path, "a+");
        }

        _logFile.writeln(message);
        if (isFlush)
        {
            _logFile.flush;
        }
    }
}

class MultiLogger : BaseLogger
{
    protected
    {
        BaseLoggerHandler[] handlers;

        shared Mutex _mutex;
    }

    this()
    {
        _mutex = new shared Mutex;
    }

    void add(BaseLoggerHandler handler)
    {
        handlers ~= handler;
    }

    protected void writeLog(LogLevel level, const(char)[] msg, string file, ulong line, string funcName)
    {
        import std.format : format;

        auto timestamp = Clock.currTime.toUTC;

        auto result = format("%s [%s] %s:%d:%s %s",
            timestamp.toSimpleString,
            levelToStr(level),
            file,
            line,
            funcName,
            msg);

        foreach (h; handlers)
        {
            h.output(level, result);
        }
    }

    void log(LogLevel level, const(char)[] msg, string file, ulong line, string funcName)
    {
        synchronized (_mutex)
        {
            if (!isForLevel(level))
            {
                return;
            }

            writeLog(level, msg, file, line, funcName);
        }
    }

    void log(const(char)[] message, string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__)
    {
        log(_level, message, file, line, func);
    }

    void trace(const(char)[] message, string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__)
    {
        log(LogLevel.trace, message, file, line, func);
    }

    void info(const(char)[] message, string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__)
    {
        log(LogLevel.info, message, file, line, func);
    }

    void warning(const(char)[] message, string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__)
    {
        log(LogLevel.warning, message, file, line, func);
    }

    void error(const(char)[] message, string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__)
    {
        log(LogLevel.error, message, file, line, func);
    }

    void logf(string file, size_t line, string func, Args...)(LogLevel level, const(char)[] formatMsg, Args args)
    {
        synchronized (_mutex)
        {
            if (!isForLevel(level))
            {
                return;
            }

            import std.format : format;

            auto result = format(formatMsg, args);
            writeLog(level, result, file, line, func);
        }

    }

    void tracef(string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__, Args...)(Args args)
    {
        logf!(file, line, func)(LogLevel.trace, args);
    }

    void infof(string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__, Args...)(Args args)
    {
        logf!(file, line, func)(LogLevel.info, args);
    }

    void warningf(string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__, Args...)(Args args)
    {
        logf!(file, line, func)(LogLevel.warning, args);
    }

    void errorf(string file = __FILE__, size_t line = __LINE__,
        string func = __PRETTY_FUNCTION__, Args...)(Args args)
    {
        logf!(file, line, func)(LogLevel.error, args);
    }
}

unittest
{
    auto handler = new MultiLogger;

    auto logger = new Logger;
    logger.add(handler);
    logger.level = LogLevel.warning;

    logger.warningf("This is info: %s", 5);
}
