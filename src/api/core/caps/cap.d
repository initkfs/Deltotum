module api.core.caps.cap;

import api.core.components.component_service : ComponentService;
import api.core.caps.core.cap_core : CapCore;

/**
 * Authors: initkfs
 */
class Cap : ComponentService
{
    CapCore capCore;

    this(CapCore capCore) pure @safe
    {
        assert(capCore);
        this.capCore = capCore;
    }

    this(const CapCore capCore) const pure @safe
    {
        assert(capCore);
        this.capCore = capCore;
    }

    this(immutable CapCore capCore) immutable pure @safe
    {
        assert(capCore);
        this.capCore = capCore;
    }

    immutable(Cap) idup() immutable pure @safe
    {
        return new immutable Cap(capCore.idup);
    }
}
