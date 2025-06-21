module api.core.contexts.locators.locator_context;

import std.variant;

/**
 * Authors: initkfs
 */

class LocatorContext
{
    private
    {
        Variant[string] variants;
        Object[string] objects;
    }

    this() pure @safe
    {

    }

    this(immutable Variant[string] variants, immutable Object[string] objects) immutable pure @safe
    {
        this.variants = variants;
        this.objects = objects;
    }

    inout(Variant*) hasVarPtr(string key) inout pure @safe
    {
        import std.exception : enforce;

        enforce(key.length > 0, "Key must not be empty");
        return (key in variants);
    }

    bool hasVar(string key) const pure @safe => hasVarPtr(key) !is null;

    bool putVar(string key, Variant value)
    {
        if (hasVar(key))
        {
            return false;
        }

        if (!value.hasValue)
        {
            throw new Exception("Variant does not contain a value for key: " ~ key);
        }

        variants[key] = value;

        return true;
    }

    inout(Variant) getVar(string key) inout
    {
        if (auto varPtr = hasVarPtr(key))
        {
            return *varPtr;

        }

        throw new Exception("Not found variant with key: " ~ key);
    }

    inout(T) getVarTo(T)(string key) inout
    {
        Variant service = getVar(key);
        if (!service.convertsTo!T)
        {
            import std.format : format;

            throw new Exception(format("Variant with key '%s' and type '%s' cannot be converted to type '%s'", key, service
                    .type(), T.stringof));
        }
        return service.get!T;
    }

    inout(Object*) hasObjectPtr(string key) inout pure @safe
    {
        import std.exception : enforce;

        enforce(key.length > 0, "Key must not be empty");
        return (key in objects);
    }

    bool hasObject(string key) const pure @safe => hasObjectPtr(key) !is null;

    bool putObject(string key, Object value)
    {
        if (hasObject(key))
        {
            return false;
        }

        objects[key] = value;
        return true;
    }

    inout(Object) getObject(string key) inout
    {
        if (auto objPtr = hasObjectPtr(key))
        {
            return *objPtr;
        }

        throw new Exception("Not found object with key: " ~ key);
    }

    immutable(LocatorContext) idup()
    {
        import std.conv : to;

        return new immutable LocatorContext(variants.to!(immutable(typeof(variants))), objects.to!(
                immutable(typeof(objects))));
    }
}

unittest
{
    import std.exception : assertThrown;

    string key1 = "key";

    auto locator = new LocatorContext;
    Variant a;
    assertThrown(locator.putVar(key1, a));
    a = 5;
    assert(locator.putVar(key1, a));
    assert(!locator.putVar(key1, a));
    assert(locator.hasVar(key1));
    assert(locator.getVarTo!int(key1) == 5);
    assertThrown(locator.getVarTo!string(key1) == "5");

    int delegate() factory = () => 5;
    string fkey = "fkey";
    Variant f = factory;
    assert(locator.putVar(fkey, f));
    assertThrown(locator.getVarTo!(string delegate())(fkey));
    assert(locator.getVarTo!(int delegate())(fkey)() == 5);

    immutable immLocator = locator.idup;
    assert(immLocator.hasVar(key1));
    assert(immLocator.getVarTo!int(key1) == 5);
}
