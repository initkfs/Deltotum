module api.core.configs.null_configuration;

import api.core.configs.configs : Configuration;
import api.core.configs.keyvalues.null_config : NullConfig;

/**
 * Authors: initkfs
*/
class NullConfiguration : Configuration
{
    this() @safe
    {
        super(new NullConfig);
    }

    this() const @safe
    {
        const nc = new const NullConfig;
        super(nc);
    }

    this() immutable @safe
    {
        super(new immutable NullConfig);
    }
}
