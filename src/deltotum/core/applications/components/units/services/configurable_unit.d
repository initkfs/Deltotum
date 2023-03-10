module deltotum.core.applications.components.units.services.configurable_unit;

import deltotum.core.configs.config : Config;

/**
 * Authors: initkfs
 */
class ConfigurableUnit
{
    private
    {
        Config _config;
    }

    @safe pure this(Config config)
    {
        import std.exception : enforce;

        enforce(config !is null, "Config must not be null");

        this._config = config;
    }

    Config config() @safe pure nothrow @nogc
    {
        return _config;
    }
}
