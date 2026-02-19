module api.core.loggers.builtins.handlers.base_log_handler;

import api.core.loggers.builtins.base_logger : BaseLogger, LogLevel;

/**
 * Authors: initkfs
 */

abstract class BaseLogHandler : BaseLogger
{
    abstract
    {
        void output(LogLevel level, const(char)[] message);
    }
}
