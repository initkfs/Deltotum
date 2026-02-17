module api.core.loggers.logging;

import api.core.components.component_service : ComponentService;

import api.core.loggers.slogger.logger : Logger;

/**
 * Authors: initkfs
 */
class Logging : ComponentService
{
    Logger logger;

    this(Logger logger) pure @safe
    {
        assert(logger);
        this.logger = logger;
    }

    this(const(Logger) logger) const pure @safe
    {
        assert(logger);
        this.logger = logger;
    }

    this(immutable Logger logger) immutable pure @safe
    {
        assert(logger);
        this.logger = logger;
    }
}
