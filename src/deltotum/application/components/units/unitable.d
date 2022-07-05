module deltotum.application.components.units.unitable;

/**
 * Authors: initkfs
 */
class Unitable
{
    string getClassName() @safe pure nothrow const
    {
        return this.classinfo.name;
    }
}
