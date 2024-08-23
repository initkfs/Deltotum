module api.core.components.units.services.loggable_unit;

import api.core.components.units.simple_unit : SimpleUnit;

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

        enforce(logger, "Logger must not be null");

        this._logger = logger;
    }

    this(const Logger logger) const pure @safe
    {
        import std.exception : enforce;

        enforce(logger, "Logger for constant object must not be null");

        this._logger = logger;
    }

    this(immutable Logger logger) immutable pure @safe
    {
        import std.exception : enforce;

        enforce(logger, "Logger for immutable object must not be null");

        this._logger = logger;
    }

    inout(Logger) logger() inout nothrow pure @safe => _logger;
}

unittest
{
    import std.logger : NullLogger, LogLevel;
    import std.traits : isMutable;
    import std.conv : to;

    const(Logger) nlc = new NullLogger(LogLevel.all);
    const(LoggableUnit) lc = new const LoggableUnit(nlc);
    assert(!isMutable!(typeof(lc.logger)));

    immutable nli = cast(immutable(NullLogger)) new NullLogger(LogLevel.all);
    auto li = new immutable LoggableUnit(nli);
    assert(!isMutable!(typeof(li.logger)));
}
