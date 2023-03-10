module deltotum.core.applications.components.units.services.application_unit;

import deltotum.core.applications.components.units.services.loggable_unit: LoggableUnit;
import deltotum.core.applications.contexts.context: Context;
import deltotum.core.configs.config: Config;

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

    this(Logger logger, Config config, Context context) @safe
    {
        super(logger);
        import std.exception : enforce;

        enforce(config !is null, "Config must not be null");
        enforce(context !is null, "Context must not be null");

        this._config = config;
        this._context = context;
    }

    Config config() @safe pure nothrow @nogc
    {
        return _config;
    }

    Context context() @safe pure nothrow @nogc
    {
        return _context;
    }
}
