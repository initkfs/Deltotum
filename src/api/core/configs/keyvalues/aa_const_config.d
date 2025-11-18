module api.core.configs.keyvalues.aa_const_config;

import api.core.configs.keyvalues.config : Config;

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

    override bool load() const => false;
    override bool save() const => false;
    override bool clear() const => false;

    override bool hasKey(string key) const => containsPtr(key) !is null;

    const(V*) containsPtr(string key) const
    {
        assert(key.length > 0);
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

    bool setValue(T)(string key, T value) const => false;

    override bool getBool(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found boolean value in AA config with key: " ~ key);
        }
        return getValue!bool(valuePtr);
    }

    override bool setBool(string key, bool value) const => false;

    override string getString(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found string value in AA config with key: " ~ key);
        }

        return getValue!string(valuePtr);
    }

    override bool setString(string key, string value) const => false;

    override int getInt(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found integer value in AA config with key: " ~ key);
        }
        return getValue!int(valuePtr);
    }

    override bool setInt(string key, int value) => false;

    override long getLong(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            throw new Exception("Not found long value in AA config with key: " ~ key);
        }
        return getValue!long(valuePtr);
    }

    override bool setLong(string key, long value) const => false;

    override double getDouble(string key) const
    {
        const valuePtr = containsPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found double value in AA config with key: " ~ key);
        }

        return getValue!double(valuePtr);
    }

    override bool setDouble(string key, double value) const => false;

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

    import std.conv: to;

    auto val1 = config.getLong("value1");
    assert(val1 == 1, val1.to!string);

    auto val2 = config.getString("value2");
    assert(val2 == "random text", val2.to!string);

    auto val3 = config.getDouble("value3");
    assert(isClose(val3, 2.5), val3.to!string);

    auto val4 = config.getBool("value4");
    assert(val4 == true);

    assert(!config.setValue("value1", 2));
    assert(!config.setValue("value2", "text"));
    assert(!config.setValue("value3", 10.5));
    assert(!config.setValue("value4", false));
}
