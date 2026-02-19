module api.core.loggers.null_logging;

import api.core.loggers.logging : Logging;
import api.core.loggers.builtins.logger: Logger;

/**
 * Authors: initkfs
 */
class NullLogging : Logging
{
    this() @safe
    {
        super(new Logger);
    }

    this() const @safe
    {
        super(new Logger);
    }

    this() immutable @safe
    {
        super(() @trusted {
            return cast(immutable(Logger)) new Logger;
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
