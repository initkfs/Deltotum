module dm.core.locators.service_locator;

import dm.core.components.units.services.loggable_unit : LoggableUnit;

import std.logger.core : Logger;
import std.variant;

/**
 * Authors: initkfs
 */
//TODO logging
class ServiceLocator : LoggableUnit
{
    private
    {
        Variant[string] services;
    }

    this(Logger logger) pure @safe
    {
        super(logger);
    }

    bool put(string key, Variant value)
    {
        if (has(key))
        {
            return false;
        }

        if (!value.hasValue)
        {
            throw new Exception("Variant does not contain a value for key: " ~ key);
        }

        services[key] = value;

        return true;
    }

    T getTo(T)(string key)
    {
        Variant service = get(key);
        if (!service.convertsTo!T)
        {
            import std.format : format;

            throw new Exception(format("Variant with key '%s' and type '%s' cannot be converted to type '%s'", key, service
                    .type(), T.stringof));
        }
        return service.get!T;
    }

    inout(Variant) get(string key) inout
    {
        if (!has(key))
        {
            throw new Exception("Not found service with key: " ~ key);
        }

        return services[key];
    }

    bool has(string key) const pure @safe
    {
        import std.exception : enforce;

        enforce(key.length > 0, "Key must not be empty");
        return (key in services) !is null;
    }
}

unittest
{
    import std.logger.nulllogger;

    import std.exception : assertThrown;

    string key1 = "key";

    auto locator = new ServiceLocator(new NullLogger());
    Variant a;
    assertThrown(locator.put(key1, a));
    a = 5;
    assert(locator.put(key1, a));
    assert(!locator.put(key1, a));
    assert(locator.has(key1));
    assert(locator.getTo!int(key1) == 5);
    assertThrown(locator.getTo!string(key1) == "5");

    int delegate() factory = () => 5;
    string fkey = "fkey";
    Variant f = factory;
    assert(locator.put(fkey, f));
    assertThrown(locator.getTo!(string delegate())(fkey));
    assert(locator.getTo!(int delegate())(fkey)() == 5);
}
