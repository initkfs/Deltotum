module api.core.resources.resourcing;

import api.core.components.component_service: ComponentService;
import api.core.resources.locals.local_resources: LocalResources;

import api.core.loggers.logging : Logging;

class Resourcing : ComponentService
{
    LocalResources local;
    
    this(LocalResources localRes) pure @safe
    {
        assert(localRes);
        this.local = localRes;
    }

    this(const LocalResources localRes) const pure @safe
    {
        assert(localRes);
        this.local = localRes;
    }

    this(immutable LocalResources localRes) immutable pure @safe
    {
        assert(localRes);
        this.local = localRes;
    }
}
