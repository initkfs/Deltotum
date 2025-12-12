module api.core.components.units.services.application_unit;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;

import api.core.loggers.logging : Logging;

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

    this(Logging logging, Config config, Context context) pure @safe
    {
        super(logging);

        if (!config)
        {
            throw new Exception("Config must not be null");
        }

        if (!context)
        {
            throw new Exception("Context must not be null");
        }

        this._config = config;
        this._context = context;
    }

    this(const Logging logging, const Config config, const Context context) const pure @safe
    {
        super(logging);

        if (!config)
        {
            throw new Exception("Config must not be null");
        }

        if (!context)
        {
            throw new Exception("Context must not be null");
        }

        this._config = config;
        this._context = context;
    }

    this(immutable Logging logging, immutable Config config, immutable Context context) immutable pure @safe
    {
        super(logging);

        if (!config)
        {
            throw new Exception("Config must not be null");
        }

        if (!context)
        {
            throw new Exception("Context must not be null");
        }

        this._config = config;
        this._context = context;
    }

    inout(Config) config() inout nothrow pure @safe => _config;
    inout(Context) context() inout nothrow pure @safe => _context;
}
