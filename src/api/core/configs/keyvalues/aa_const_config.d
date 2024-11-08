module api.core.configs.keyvalues.aa_const_config;

import api.core.configs.keyvalues.config : Config;
import api.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import api.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.typecons : Nullable;
import std.conv : to;

/**
 * Authors: initkfs
 * TODO remove code duplications
 */
class AAConstConfig(V = string) : Config
{
    V[string] config;

    this(V[string] config) pure @safe
    {
        this.config = config;
    }

    this(const V[string] config) const pure @safe
    {
        this.config = config;
    }

    this(immutable V[string] config) immutable
    {
        this.config = config;
    }

    override bool load() const
    {
        return false;
    }

    override bool save() const
    {
        return false;
    }

    override bool clear() const
    {
        return false;
    }

    override bool containsKey(string key) const
    {
        return containsPtr(key) !is null;
    }

    const(V*) containsPtr(string key) const
    {
        return key in config;
    }

    T getValue(T)(const(V*) valuePtr) const
    {
        return (*valuePtr).to!T;
    }

    T getValue(T)(string key) const
    {
        return config[key].to!T;
    }

    bool setValue(T)(string key, T value) const
    {
        return false;
    }

    override Nullable!bool getBool(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found boolean value in AA config with key: " ~ key);
            }
            else
            {
                return Nullable!bool.init;
            }
        }
        const bool value = getValue!bool(valuePtr);
        return Nullable!bool(value);
    }

    override bool setBool(string key, bool value) const
    {
        return false;
    }

    override Nullable!string getString(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found string value in AA config with key: " ~ key);
            }
            else
            {
                return Nullable!string.init;
            }
        }

        const strValue = getValue!string(valuePtr);
        return Nullable!string(strValue);
    }

    override bool setString(string key, string value) const
    {
        return false;
    }

    override Nullable!long getLong(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found integer value in AA config with key: " ~ key);
            }
            else
            {
                return Nullable!long.init;
            }
        }
        const long value = getValue!long(valuePtr);
        return Nullable!long(value);
    }

    override bool setLong(string key, long value) const
    {
        return false;
    }

    override Nullable!double getDouble(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found double value in AA config with key: " ~ key);
            }
            else
            {
                return Nullable!double.init;
            }
        }

        const double value = getValue!double(valuePtr);
        return Nullable!double(value);
    }

    override bool setDouble(string key, double value) const
    {
        return false;
    }

    T[] getList(T)(string key) const
    {
        throw new Exception("Non supported yet");
    }

    override string toText() const
    {
        import std.conv : to;

        return config.to!string;
    }

    override immutable(AAConstConfig) idup() const
    {
        //TODO unsafe hack        
        immutable newConfig = cast(immutable(V[string])) config;
        return new immutable AAConstConfig(newConfig);
    }
}

unittest
{
    import std.math.operations : isClose;

    immutable aa = [
        "value1": "1",
        "value2": "random text",
        "value3": "2.5",
        "value4": "true"
    ];

    immutable config = new immutable AAConstConfig!string(aa);

    assert(aa == config.config);

    assert(!config.load);
    assert(!config.save);

    auto val1 = config.getLong("value1");
    assert(!val1.isNull);
    assert(val1 == 1, val1.toString);

    auto val2 = config.getString("value2");
    assert(!val2.isNull);
    assert(val2 == "random text", val2.toString);

    auto val3 = config.getDouble("value3");
    assert(!val3.isNull);
    assert(isClose(val3, 2.5), val3.toString);

    auto val4 = config.getBool("value4");
    assert(!val4.isNull);
    assert(val4 == true);

    assert(!config.setValue("value1", 2));
    assert(!config.setValue("value2", "text"));
    assert(!config.setValue("value3", 10.5));
    assert(!config.setValue("value4", false));
}
