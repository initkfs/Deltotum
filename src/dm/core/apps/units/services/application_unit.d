module dm.core.apps.units.services.application_unit;

import dm.core.apps.units.services.loggable_unit : LoggableUnit;
import dm.core.contexts.context : Context;
import dm.core.configs.config : Config;

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

    this(const Logger logger, const Config config, const Context context) const pure @safe
    {
        super(logger);
        import std.exception : enforce;

        enforce(config !is null, "Config for constant object must not be null");
        enforce(context !is null, "Context for constant object must not be null");

        this._config = config;
        this._context = context;
    }

    inout(Config) config() inout @nogc nothrow pure @safe
    {
        return _config;
    }

    inout(Context) context() inout @nogc nothrow pure @safe
    {
        return _context;
    }
}
