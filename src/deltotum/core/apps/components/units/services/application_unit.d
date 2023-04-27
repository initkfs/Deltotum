module deltotum.core.apps.components.units.services.application_unit;

import deltotum.core.apps.components.units.services.loggable_unit : LoggableUnit;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class ApplicationUnit : LoggableUnit
{
    private
    {
        Config _config;
        Context _context;
    }

    this(Logger logger, Config config, Context context) pure @safe
    {
        super(logger);
        import std.exception : enforce;

        enforce(config !is null, "Config must not be null");
        enforce(context !is null, "Context must not be null");

        this._config = config;
        this._context = context;
    }

    Config config() @nogc nothrow pure @safe
    {
        return _config;
    }

    Context context() @nogc nothrow pure @safe
    {
        return _context;
    }
}
