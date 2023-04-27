module deltotum.core.apps.units.unitable;

/**
 * Authors: initkfs
 */
class Unitable
{
    string className() const nothrow pure @safe
    {
        return this.classinfo.name;
    }
}
