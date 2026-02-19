module api.core.loggers.builtins.handlers.console_handler;

import api.core.loggers.builtins.base_logger: LogLevel;
import api.core.loggers.builtins.handlers.base_log_handler: BaseLogHandler;

/**
 * Authors: initkfs
 */
class ConsoleHandler : BaseLogHandler
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