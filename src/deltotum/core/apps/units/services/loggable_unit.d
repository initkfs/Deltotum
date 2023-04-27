module deltotum.core.apps.units.services.loggable_unit;

import deltotum.core.apps.units.simple_unit: SimpleUnit;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class LoggableUnit : SimpleUnit
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
    {
        return _logger;
    }
}
