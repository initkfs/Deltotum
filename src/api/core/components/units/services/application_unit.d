module api.core.components.units.services.application_unit;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.core.contexts.context : Context;
import api.core.configs.config : Config;

import api.core.loggers.loggers : Logging;

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

    this(Logging loggers, Config config, Context context) pure @safe
    {
        super(loggers);
        import std.exception : enforce;

        enforce(config, "Config must not be null");
        enforce(context, "Context must not be null");

        this._config = config;
        this._context = context;
    }

    this(const Logging loggers, const Config config, const Context context) const pure @safe
    {
        super(loggers);
        import std.exception : enforce;

        enforce(config, "Config for constant object must not be null");
        enforce(context, "Context for constant object must not be null");

        this._config = config;
        this._context = context;
    }

    this(immutable Logging loggers, immutable Config config, immutable Context context) immutable pure @safe
    {
        super(loggers);
        import std.exception : enforce;

        enforce(config, "Config for immutable object must not be null");
        enforce(context, "Context for immutable object must not be null");

        this._config = config;
        this._context = context;
    }

    inout(Config) config() inout nothrow pure @safe => _config;
    inout(Context) context() inout nothrow pure @safe => _context;
}
