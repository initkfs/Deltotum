module api.core.resources.null_resource;

import api.core.resources.resource : Resource;
import api.core.loggers.null_logging: NullLogging;

class NullResource : Resource
{
    this() @safe
    {
        super(new NullLogging);
    }
}
