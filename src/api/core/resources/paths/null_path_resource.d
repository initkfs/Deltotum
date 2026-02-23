module api.core.resources.paths.null_path_resource;

import api.core.resources.paths.path_resource : PathResource;
import api.core.loggers.null_logging : NullLogging;

class NullPathResources : PathResource
{
    this() @safe
    {
        super(new NullLogging);
    }

    this() const @safe
    {
        super(new const NullLogging);
    }

    this() immutable @safe
    {
        super(new immutable NullLogging);
    }
}
