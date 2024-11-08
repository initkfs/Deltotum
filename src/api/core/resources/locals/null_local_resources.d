module api.core.resources.locals.null_local_resources;

import api.core.resources.locals.local_resources : LocalResources;
import api.core.loggers.null_logging: NullLogging;

class NullLocalResources : LocalResources
{
    this() @safe
    {
        super(new NullLogging);
    }
}
