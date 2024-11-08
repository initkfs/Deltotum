module api.core.loggers.null_logging;

import api.core.loggers.logging : Logging;

import std.logger : NullLogger;

/**
 * Authors: initkfs
 */
class NullLogging : Logging
{
    this() @safe
    {
        super(new NullLogger);
    }

    this() const @safe
    {
        super(new NullLogger);
    }

    this() immutable @safe
    {
        super(() @trusted {
            return cast(immutable(NullLogger)) new NullLogger;
        }());
    }
}

unittest
{
    import std.traits : isMutable;

    auto nl = new NullLogging;
    assert(isMutable!(typeof(nl.logger)));

    const nl1 = new NullLogging;
    assert(!isMutable!(typeof(nl1.logger)));

    immutable nl2 = new immutable NullLogging;
    assert(!isMutable!(typeof(nl2.logger)));
}
