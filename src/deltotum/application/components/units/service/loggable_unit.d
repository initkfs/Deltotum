module deltotum.application.components.units.service.loggable_unit;

import std.experimental.logger.core : Logger;

/**
 * Authors: initkfs
 */
class LoggableUnit
{
    private
    {
        Logger _logger;
    }

    @safe pure this(Logger logger)
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");

        this.logger = logger;
    }

    @property Logger logger() @safe pure nothrow
    out (_logger; _logger !is null)
    {
        return _logger;
    }

    @property void logger(Logger logger) @safe pure
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");
        _logger = logger;
    }
}
