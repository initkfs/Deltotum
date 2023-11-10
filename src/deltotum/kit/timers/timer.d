module deltotum.kit.timers.timer;

import deltotum.core.apps.units.services.loggable_unit : LoggableUnit;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class Timer : LoggableUnit
{
    ulong delegate() tickProvider;

    this(Logger logger)
    {
        super(logger);
    }

    ulong ticks()
    {
        assert(tickProvider);
        return tickProvider();
    }
}
