module deltotum.application.components.units.service.loggable_unit;

import std.experimental.logger.core : Logger;

/**
 * Authors: initkfs
 */
class LoggableUnit
{
    private
    {
        const Logger _logger;
    }

    this(Logger logger)
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");

        this._logger = logger;
    }

    Logger logger() @safe pure nothrow
    out (_logger; _logger !is null)
    {
        return _logger;
    }
}
