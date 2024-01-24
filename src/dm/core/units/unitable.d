module dm.core.units.unitable;

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
        return classNameShort(className);
    }

    string classNameShort(string name, string nameSep = ".") const pure @safe
    {
        assert(nameSep.length > 0);

        if (name.length == 0)
        {
            return name;
        }

        import std.string : lastIndexOf;

        immutable lastSepIndex = name.lastIndexOf(nameSep);
        if (lastSepIndex == -1)
        {
            return name;
        }

        auto mustBeName = name[(lastSepIndex + 1) .. $];
        return mustBeName.length > 0 ? mustBeName : name;
    }
}

unittest
{
    auto unit = new Unitable;
    assert(unit.classNameShort("") == "");
    assert(unit.classNameShort("foo.") == "foo.");
    assert(unit.classNameShort(".") == ".");
    assert(unit.classNameShort("foo.bar") == "bar");
}
