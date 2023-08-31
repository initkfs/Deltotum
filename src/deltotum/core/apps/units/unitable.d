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

    string classNameShort() const pure @safe
    {
        const name = className;
        import std.string : lastIndexOf;
        import std.exception: collectException;

        enum nameSep = '.';
        const lastSepIndex = name.lastIndexOf(nameSep);
        if (lastSepIndex == -1)
        {
            return name;
        }

        return name[lastSepIndex + 1 .. $];
    }
}
