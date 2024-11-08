module api.core.components.units.services.loggable_unit;

import api.core.components.units.simple_unit : SimpleUnit;

import api.core.loggers.loggers : Logging;

import std.logger: Logger;

/**
 * Authors: initkfs
 */
class LoggableUnit : SimpleUnit
{
    private
    {
        Logging _loggers;
    }

    this(Logging loggers) pure @safe
    {
        import std.exception : enforce;

        enforce(loggers, "Logging must not be null");

        this._loggers = loggers;
    }

    this(const Logging loggers) const pure @safe
    {
        import std.exception : enforce;

        enforce(loggers, "Logging for constant object must not be null");

        this._loggers = loggers;
    }

    this(immutable Logging loggers) immutable pure @safe
    {
        import std.exception : enforce;

        enforce(loggers, "Logging for immutable object must not be null");

        this._loggers = loggers;
    }

    inout(Logging) loggers() inout nothrow pure @safe => _loggers;
    inout(Logger) logger() inout nothrow pure @safe => _loggers.logger;
}

unittest
{
    import api.core.loggers.loggers: Logging;
    import std.logger : NullLogger, LogLevel;
    import std.traits : isMutable;
    import std.conv : to;

    const(Logger) nlc = new NullLogger(LogLevel.all);
    const loggers = new const Logging(nlc);
    const(LoggableUnit) lc = new const LoggableUnit(loggers);
    assert(!isMutable!(typeof(lc.loggers)));
    assert(!isMutable!(typeof(lc.logger)));

    immutable nli = cast(immutable(NullLogger)) new NullLogger(LogLevel.all);
    immutable loggingi = new immutable Logging(nli);
    auto li = new immutable LoggableUnit(loggingi);
    assert(!isMutable!(typeof(li.loggers)));
}
