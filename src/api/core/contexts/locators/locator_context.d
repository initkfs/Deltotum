module api.core.contexts.locators.locator_context;

/**
 * Authors: initkfs
 */

struct LocatorItem
{
    void* ptr;
    TypeInfo type;
}

class LocatorContext
{
    private
    {
        LocatorItem[string] variants;
        Object[string] objects;
    }

    this() pure @safe
    {

    }

    this(immutable LocatorItem[string] variants, immutable Object[string] objects) immutable pure @safe
    {
        this.variants = variants;
        this.objects = objects;
    }

    inout(LocatorItem*) hasVarPtr(string key) inout pure @safe
    {
        if (key.length == 0)
        {
            throw new Exception("Key must not be empty");
        }
        return (key in variants);
    }

    bool hasVar(string key) const pure @safe => hasVarPtr(key) !is null;

    bool putVar(T)(string key, T* value)
    {
        if (hasVar(key))
        {
            return false;
        }

        static if (__traits(compiles, value is null))
        {
            if (!value)
            {
                throw new Exception("Value must not be null for key: " ~ key);
            }
        }

        variants[key] = LocatorItem(value, typeid(value));

        return true;
    }

    inout(LocatorItem*) getVar(string key) inout
    {
        if (auto varPtr = hasVarPtr(key))
        {
            return varPtr;

        }
        throw new Exception("Not found value for key: " ~ key);
    }

    inout(T) getVarTo(T)(string key) inout
    {
        auto item = getVar(key);

        if (item.type != typeid(T*))
        {
            import std.format : format;

            throw new Exception(format("Variant with key '%s' and type '%s' cannot be converted to type '%s'", key, item
                    .type, T.stringof));
        }

        T* tPtr = cast(T*) item.ptr;
        return *tPtr;
    }

    inout(Object*) hasObjectPtr(string key) inout pure @safe
    {
        if (key.length == 0)
        {
            throw new Exception("Key must not be empty");
        }
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

        immutable(typeof(variants)) vars = cast(immutable(typeof(variants))) variants.dup;

        return new immutable LocatorContext(vars, objects.to!(
                immutable(typeof(objects))));
    }
}

unittest
{
    import std.exception : assertThrown;

    string key1 = "key";

    auto locator = new LocatorContext;
    int* a = new int(5);
    assert(locator.putVar(key1, a));
    assert(!locator.putVar(key1, a));
    assert(locator.hasVar(key1));
    assert(locator.getVarTo!int(key1) == 5);
    assertThrown(locator.getVarTo!string(key1) == "5");

    int delegate() factory = () => 5;
    string fkey = "fkey";
    auto f = &factory;
    assert(locator.putVar(fkey, f));
    assertThrown(locator.getVarTo!(string delegate())(fkey));
    assert(locator.getVarTo!(int delegate())(fkey)() == 5);

    immutable immLocator = locator.idup;
    assert(immLocator.hasVar(key1));
    assert(immLocator.getVarTo!int(key1) == 5);
}
