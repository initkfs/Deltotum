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

    this(Config config) pure @safe
    {
        import std.exception : enforce;

        enforce(config !is null, "Config must not be null");

        this._config = config;
    }

    Config config() @nogc nothrow pure @safe
    {
        return _config;
    }
}
