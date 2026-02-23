module api.core.resources.resourcing;

import api.core.components.component_service : ComponentService;
import api.core.resources.paths.path_resource : PathResource;

import api.core.loggers.logging : Logging;

class Resourcing : ComponentService
{
    PathResource user;

    this(PathResource userRes) pure @safe
    {
        assert(userRes);
        this.user = userRes;
    }

    this(const PathResource userRes) const pure @safe
    {
        assert(userRes);
        this.user = userRes;
    }

    this(immutable PathResource userRes) immutable pure @safe
    {
        assert(userRes);
        this.user = userRes;
    }
}
