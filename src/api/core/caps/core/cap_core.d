module api.core.caps.core.cap_core;

/**
 * Authors: initkfs
 */
class CapCore
{
    immutable(CapCore) idup() immutable pure @safe
    {
        return new CapCore;
    }
}
