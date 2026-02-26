module api.dm.kit.assets.paths.null_path_resource;

import api.dm.kit.assets.paths.path_resource : PathResource;
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
