module deltotum.core.applications.components.units.unitable;

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
