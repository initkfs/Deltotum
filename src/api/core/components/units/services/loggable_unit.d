module api.core.components.units.services.loggable_unit;

import api.core.components.units.simple_unit : SimpleUnit;

import api.core.loggers.logging : Logging;

import api.core.loggers.slogger.logger : Logger;

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
        if (!logging)
        {
            throw new Exception("Logging must not be null");
        }

        this._logging = logging;
    }

    this(const Logging logging) const pure @safe
    {
        if (!logging)
        {
            throw new Exception("Logging must not be null");
        }

        this._logging = logging;
    }

    this(immutable Logging logging) immutable pure @safe
    {
        if (!logging)
        {
            throw new Exception("Logging must not be null");
        }

        this._logging = logging;
    }

    inout(Logging) logging() inout nothrow pure @safe => _logging;
    inout(Logger) logger() inout nothrow pure @safe => _logging.logger;
}

unittest
{
    import api.core.loggers.logging : Logging;
    import api.core.loggers.slogger.logger_level: LogLevel;
    import std.traits : isMutable;
    import std.conv : to;

    const(Logger) nlc = new Logger(LogLevel.all);
    const logging = new const Logging(nlc);
    const(LoggableUnit) lc = new const LoggableUnit(logging);
    assert(!isMutable!(typeof(lc.logging)));
    assert(!isMutable!(typeof(lc.logger)));

    immutable nli = cast(immutable(Logger)) new Logger(LogLevel.all);
    immutable loggingi = new immutable Logging(nli);
    auto li = new immutable LoggableUnit(loggingi);
    assert(!isMutable!(typeof(li.logging)));
}
