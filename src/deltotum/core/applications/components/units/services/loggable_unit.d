module deltotum.core.applications.components.units.services.loggable_unit;

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

    this(Logger logger) pure @safe
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger must not be null");

        this._logger = logger;
    }

    Logger logger() @nogc nothrow pure @safe
    out (_logger; _logger !is null)
    {
        return _logger;
    }
}
