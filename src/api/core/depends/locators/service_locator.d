module api.core.depends.locators.service_locator;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.core.loggers.logging : Logging;
import std.variant;

/**
 * Authors: initkfs
 */
//TODO logging
class ServiceLocator : LoggableUnit
{
    private
    {
        Variant[string] variants;
        Object[string] objects;
    }

    this(Logging logging) pure @safe
    {
        super(logging);
    }

    this(const Logging logging) const pure @safe
    {
        super(logging);
    }

    this(immutable Logging logging) immutable pure @safe
    {
        super(logging);
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

    T getVarTo(T)(string key)
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
}

unittest
{
    import api.core.loggers.null_logging : NullLogging;

    import std.exception : assertThrown;

    string key1 = "key";

    auto locator = new ServiceLocator(new NullLogging());
    Variant a;
    assertThrown(locator.put(key1, a));
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
}
