module core.components.units.services.application_unit;

import core.components.units.services.loggable_unit : LoggableUnit;
import core.contexts.context : Context;
import core.configs.config : Config;

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

        enforce(config, "Config must not be null");
        enforce(context, "Context must not be null");

        this._config = config;
        this._context = context;
    }

    this(const Logger logger, const Config config, const Context context) const pure @safe
    {
        super(logger);
        import std.exception : enforce;

        enforce(config, "Config for constant object must not be null");
        enforce(context, "Context for constant object must not be null");

        this._config = config;
        this._context = context;
    }

    this(immutable Logger logger, immutable Config config, immutable Context context) immutable pure @safe
    {
        super(logger);
        import std.exception : enforce;

        enforce(config, "Config for immutable object must not be null");
        enforce(context, "Context for immutable object must not be null");

        this._config = config;
        this._context = context;
    }

    inout(Config) config() inout nothrow pure @safe => _config;
    inout(Context) context() inout nothrow pure @safe => _context;
}
