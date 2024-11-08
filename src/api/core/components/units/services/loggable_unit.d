module api.core.components.units.services.loggable_unit;

import api.core.components.units.simple_unit : SimpleUnit;

import api.core.loggers.logging : Logging;

import std.logger: Logger;

/**
 * Authors: initkfs
 */
class LoggableUnit : SimpleUnit
{
    private
    {
        Logging _logging;
    }

    this(Logging logging) pure @safe
    {
        import std.exception : enforce;

        enforce(logging, "Logging must not be null");

        this._logging = logging;
    }

    this(const Logging logging) const pure @safe
    {
        import std.exception : enforce;

        enforce(logging, "Logging for constant object must not be null");

        this._logging = logging;
    }

    this(immutable Logging logging) immutable pure @safe
    {
        import std.exception : enforce;

        enforce(logging, "Logging for immutable object must not be null");

        this._logging = logging;
    }

    inout(Logging) logging() inout nothrow pure @safe => _logging;
    inout(Logger) logger() inout nothrow pure @safe => _logging.logger;
}

unittest
{
    import api.core.loggers.logging: Logging;
    import std.logger : NullLogger, LogLevel;
    import std.traits : isMutable;
    import std.conv : to;

    const(Logger) nlc = new NullLogger(LogLevel.all);
    const logging = new const Logging(nlc);
    const(LoggableUnit) lc = new const LoggableUnit(logging);
    assert(!isMutable!(typeof(lc.logging)));
    assert(!isMutable!(typeof(lc.logger)));

    immutable nli = cast(immutable(NullLogger)) new NullLogger(LogLevel.all);
    immutable loggingi = new immutable Logging(nli);
    auto li = new immutable LoggableUnit(loggingi);
    assert(!isMutable!(typeof(li.logging)));
}
