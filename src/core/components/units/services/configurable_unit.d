module core.components.units.services.configurable_unit;

import core.components.units.simple_unit : SimpleUnit;

import core.configs.config : Config;

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

        enforce(config, "Config must not be null");

        this._config = config;
    }

    this(const Config config) const pure @safe
    {
        import std.exception : enforce;

        enforce(config, "Config for constant object must not be null");

        this._config = config;
    }

    this(immutable Config config) immutable pure @safe
    {
        import std.exception : enforce;

        enforce(config, "Config for immutable object must not be null");

        this._config = config;
    }

    inout(Config) config() inout nothrow pure @safe
    {
        return _config;
    }
}
