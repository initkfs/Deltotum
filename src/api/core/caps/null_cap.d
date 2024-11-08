module api.core.caps.null_cap;

import api.core.caps.cap;
import api.core.caps.cap_core : CapCore;

/**
 * Authors: initkfs
 */
class NullCap : Cap
{
    this()
    {
        super(new CapCore);
    }
}
