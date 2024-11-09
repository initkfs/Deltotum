module api.core.caps.null_cap;

import api.core.caps.cap;
import api.core.caps.core.cap_core : CapCore;

/**
 * Authors: initkfs
 */
class NullCap : Cap
{
    this() @safe
    {
        super(new CapCore);
    }

    this() const @safe
    {
        super(new const CapCore);
    }

    this() immutable @safe
    {
        super(new immutable CapCore);
    }
}
