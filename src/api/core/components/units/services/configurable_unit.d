module api.core.components.units.services.configurable_unit;

import api.core.components.units.simple_unit : SimpleUnit;

import api.core.configs.configs: Configuration;
import api.core.configs.config: Config;

/**
 * Authors: initkfs
 */
class ConfigurableUnit : SimpleUnit
{
    private
    {
        Configuration _configs;
    }

    this(Configuration config) pure @safe
    {
        import std.exception : enforce;

        enforce(config, "Configuration must not be null");

        this._configs = config;
    }

    this(const Configuration config) const pure @safe
    {
        import std.exception : enforce;

        enforce(config, "Configuration for constant object must not be null");

        this._configs = config;
    }

    this(immutable Configuration config) immutable pure @safe
    {
        import std.exception : enforce;

        enforce(config, "Config for immutable object must not be null");

        this._configs = config;
    }
    
    inout(Configuration) configs() inout nothrow pure @safe => _configs;
    inout(Config) config() inout nothrow pure @safe => configs.config;
}
