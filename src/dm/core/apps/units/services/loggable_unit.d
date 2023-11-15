module dm.core.apps.units.services.loggable_unit;

import dm.core.apps.units.simple_unit : SimpleUnit;

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

    this(const Logger logger) const pure @safe
    {
        import std.exception : enforce;

        enforce(logger !is null, "Logger for constant object must not be null");

        this._logger = logger;
    }

    inout(Logger) logger() inout @nogc nothrow pure @safe
    {
        return _logger;
    }
}

unittest
{
    import std.logger : NullLogger, LogLevel;
    import std.traits: isMutable;

    const(Logger) nl = new NullLogger(LogLevel.all);
    const(LoggableUnit) lu = new const LoggableUnit(nl);
    assert(!isMutable!(typeof(lu.logger)));
}
