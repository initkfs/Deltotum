module api.core.configs.null_configuration;

import api.core.configs.configs : Configuration;
import api.core.configs.keyvalues.null_config : NullConfig;

/**
 * Authors: initkfs
*/
class NullConfiguration : Configuration
{
    this() pure @safe
    {
        super(new NullConfig);
    }

    this() const pure @safe
    {
        const nc = new const NullConfig;
        super(nc);
    }

    this() immutable pure @safe
    {
        super(new immutable NullConfig);
    }
}