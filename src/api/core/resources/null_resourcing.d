module api.core.resources.null_resourcing;

import api.core.resources.resourcing : Resourcing;
import api.core.resources.locals.null_local_resources: NullLocalResources;

class NullResourcing : Resourcing
{
    this() @safe
    {
        super(new NullLocalResources);
    }

    this() const @safe
    {
        super(new const NullLocalResources);
    }

    this() immutable @safe
    {
        super(new immutable NullLocalResources);
    }
}
