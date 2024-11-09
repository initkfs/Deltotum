module api.core.caps.null_cap;

import api.core.caps.cap;
import api.core.caps.core.cap_core : CapCore;

/**
 * Authors: initkfs
 */
class NullCap : Cap
{
    this() pure @safe
    {
        super(new CapCore);
    }

    this() const pure @safe
    {
        super(new const CapCore);
    }

    this() immutable pure @safe
    {
        super(new immutable CapCore);
    }
}
