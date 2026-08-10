module api.core.loggers.builtins.handlers.file_handler;

import api.core.loggers.builtins.base_logger : LogLevel;
import api.core.loggers.builtins.handlers.base_log_handler : BaseLogHandler;

import std.stdio : File, writeln;

/**
 * Authors: initkfs
 */
class FileHandler : BaseLogHandler
{
    protected
    {
        File* _logFile;
        string _path;
    }

    bool isFlush = true;

    this(string path)
    {
        this._path = path;
    }

    override void output(LogLevel level, const(char)[] message)
    {
        if (!isForLevel(level))
        {
            return;
        }

        if (!_logFile)
        {
            _logFile = new File(_path, "a+");
        }

        _logFile.writeln(message);
        if (isFlush)
        {
            _logFile.flush;
        }
    }

    const(string) path() => _path;
}
