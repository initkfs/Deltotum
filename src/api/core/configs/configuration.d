module api.core.configs.configs;

import api.core.components.component_service : ComponentService;
import api.core.configs.config : Config;

import std.typecons : Nullable;

/**
 * Authors: initkfs
*/
class Configuration : ComponentService
{
    Config config;

    this(Config config) pure @safe
    {
        assert(config);
        this.config = config;
    }

    this(const(Config) config) const pure @safe
    {
        assert(config);
        this.config = config;
    }

    this(immutable(Config) config) immutable pure @safe
    {
        assert(config);
        this.config = config;
    }

}

unittest
{
    import std.traits : isMutable;

    import api.core.configs.null_config : NullConfig;

    auto conf1 = new Configuration(new NullConfig);
    assert(isMutable!(typeof(conf1.config)));
    
    const nc = new const NullConfig;
    auto constConf = new const Configuration(nc);
    assert(!isMutable!(typeof(constConf.config)));

    auto immConf = new immutable Configuration(new immutable NullConfig);
    assert(!isMutable!(typeof(immConf.config)));
}
