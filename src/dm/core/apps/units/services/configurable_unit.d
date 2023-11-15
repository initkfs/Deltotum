module dm.core.apps.units.services.configurable_unit;

import dm.core.apps.units.simple_unit : SimpleUnit;

import dm.core.configs.config : Config;

/**
 * Authors: initkfs
 */
class ConfigurableUnit : SimpleUnit
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

    this(immutable Config config) immutable pure @safe
    {
        import std.exception : enforce;

        enforce(config !is null, "Config for immutable object must not be null");

        this._config = config;
    }

    inout(Config) config() inout @nogc nothrow pure @safe
    {
        return _config;
    }
}
