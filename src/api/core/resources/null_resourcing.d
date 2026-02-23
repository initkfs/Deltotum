module api.core.resources.null_resourcing;

import api.core.resources.resourcing : Resourcing;
import api.core.resources.paths.null_path_resource: NullPathResources;

class NullResourcing : Resourcing
{
    this() @safe
    {
        super(new NullPathResources);
    }

    this() const @safe
    {
        super(new const NullPathResources);
    }

    this() immutable @safe
    {
        super(new immutable NullPathResources);
    }
}
