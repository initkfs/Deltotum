module deltotum.core.application.components.units.unitable;

/**
 * Authors: initkfs
 */
class Unitable
{
    string getClassName() const nothrow pure @safe
    {
        return this.classinfo.name;
    }
}
