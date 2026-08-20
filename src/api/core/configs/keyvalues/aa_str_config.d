module api.core.configs.keyvalues.aa_str_config;

import api.core.configs.keyvalues.config : Config;

import std.conv : to;

/**
 * Authors: initkfs
 * TODO remove code duplications
 */
class AAStrConfig : Config
{
    string[string] config;

    this(string[string] config) pure @safe
    {
        this.config = config;
    }

    this(const string[string] config) const pure @safe
    {
        this.config = config;
    }

    this(immutable string[string] config) immutable
    {
        this.config = config;
    }

    override bool load() const => false;
    override bool save() const => false;

    override bool clear()
    {
        config = null;
        return true;
    }

    override bool hasKey(string key) const => hasPtr(key) !is null;

    const(string*) hasPtr(string key) const
    {
        assert(key.length > 0);
        return key in config;
    }

    T getValue(T)(const(string*) valuePtr) const => (*valuePtr).to!T;
    T getValue(T)(string key) const => config[key].to!T;

    bool setValue(T)(string key, T value)
    {
        if (auto keyPtr = key in config)
        {
            *keyPtr = value.to!string;
            return true;
        }
        return false;
    }

    override bool getBool(string key) const
    {
        const valuePtr = hasPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found boolean value in AA config with key: " ~ key);
        }
        return getValue!bool(valuePtr);
    }

    override bool setBool(string key, bool value) => setValue(key, value);

    override string getString(string key) const
    {
        const valuePtr = hasPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found string value in AA config with key: " ~ key);
        }

        return getValue!string(valuePtr);
    }

    override bool setString(string key, string value) => setValue(key, value);

    override int getInt(string key) const
    {
        const valuePtr = hasPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found integer value in AA config with key: " ~ key);
        }
        return getValue!int(valuePtr);
    }

    override bool setInt(string key, int value) => setValue(key, value);

    override long getLong(string key) const
    {
        const valuePtr = hasPtr(key);
        if (!valuePtr)
        {
            throw new Exception("Not found long value in AA config with key: " ~ key);
        }
        return getValue!long(valuePtr);
    }

    override bool setLong(string key, long value) => setValue(key, value);

    override float getFloat(string key) const
    {
        const valuePtr = hasPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found float value in AA config with key: " ~ key);
        }

        return getValue!float(valuePtr);
    }

    override bool setFloat(string key, float value) => setValue(key, value);

    override double getDouble(string key) const
    {
        const valuePtr = hasPtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found double value in AA config with key: " ~ key);
        }

        return getValue!double(valuePtr);
    }

    override bool setDouble(string key, double value) => setValue(key, value);

    T[] getList(T)(string key) const
    {
        throw new Exception("Non supported yet");
    }

    override string toText() const
    {
        import std.conv : to;

        return config.to!string;
    }

    override immutable(AAStrConfig) idup() const
    {
        //TODO unsafe hack        
        immutable newConfig = cast(immutable(string[string])) config.dup;
        return new immutable AAStrConfig(newConfig);
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

    immutable config = new immutable AAStrConfig(aa);

    assert(aa == config.config);

    assert(!config.load);
    assert(!config.save);

    import std.conv : to;

    auto val1 = config.getLong("value1");
    assert(val1 == 1, val1.to!string);

    auto val2 = config.getString("value2");
    assert(val2 == "random text", val2.to!string);

    auto val3f = config.getFloat("value3");
    assert(isClose(val3f, 2.5), val3f.to!string);

    auto val3 = config.getDouble("value3");
    assert(isClose(val3, 2.5), val3.to!string);

    auto val4 = config.getBool("value4");
    assert(val4 == true);

    //assert(config.setValue("value1", 2));
    //assert(config.getInt("value1") == 2);

    //assert(config.setValue("value2", "text"));
    //assert(config.getString("value2") == "text");
}
