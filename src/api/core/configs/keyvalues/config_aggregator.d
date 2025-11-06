module api.core.configs.keyvalues.config_aggregator;

import api.core.configs.keyvalues.config : Config;

/**
 * Authors: initkfs
*/
class ConfigAggregator : Config
{
    bool isThrowOnFailSetter = true;

    protected
    {
        Config[] _configs;
    }

    this(Config[] configs) pure @safe
    {
        this._configs = configs;
    }

    this(immutable(Config[]) configs) immutable pure @safe
    {
        this._configs = configs;
    }

    override bool load()
    {
        if (_configs.length == 0)
        {
            return false;
        }

        bool isLoad;
        foreach (config; _configs)
        {
            isLoad |= config.load;
        }
        return isLoad;
    }

    override bool save()
    {
        if (_configs.length == 0)
        {
            return false;
        }

        bool isSave;
        foreach (config; _configs)
        {
            isSave |= config.save;
        }
        return isSave;
    }

    override bool clear()
    {
        if (_configs.length == 0)
        {
            return false;
        }

        bool isClear = true;
        foreach (config; _configs)
        {
            isClear &= config.clear;
        }
        return isClear;
    }

    bool addConfig(Config config)
    {
        foreach (c; _configs)
        {
            if (c is config)
            {
                return false;
            }
        }
        _configs ~= config;
        return true;
    }

    bool removeConfigs()
    {
        if (_configs.length == 0)
        {
            return false;
        }
        _configs = null;
        return true;
    }

    size_t length() => _configs.length;

    override bool hasKey(string key) const
    {
        foreach (config; _configs)
        {
            if (config.hasKey(key))
            {
                return true;
            }
        }
        return false;
    }

    inout(Config) searchConfigOrNull(string key) inout
    {
        foreach (config; _configs)
        {
            if (config.hasKey(key))
            {
                return config;
            }
        }

        return null;
    }

    override bool getBool(string key) const
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.getBool(key);
        }

        throw new Exception("Not found boolean value in configs with key: " ~ key);
    }

    override bool setBool(string key, bool value)
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.setBool(key, value);
        }

        if (isThrowOnFailSetter)
        {
            import std.conv : text;

            throw new Exception(text("Not found config for key ", key, " and bool value ", value));
        }
        return false;
    }

    override string getString(string key) const
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.getString(key);
        }
        throw new Exception("Not found string value in configs with key: " ~ key);
    }

    override bool setString(string key, string value)
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.setString(key, value);
        }

        if (isThrowOnFailSetter)
        {
            import std.conv : text;

            throw new Exception(text("Not found config for key ", key, " and string value ", value));

        }
        return false;
    }

    override int getInt(string key) const
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.getInt(key);
        }
        throw new Exception("Not found integer value in configs with key: " ~ key);
    }

    override bool setInt(string key, int value)
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.setInt(key, value);
        }

        if (isThrowOnFailSetter)
        {
            import std.conv : text;

            throw new Exception(text("Not found config for key ", key, " and int value ", value));
        }
        return false;
    }

    override long getLong(string key) const
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.getLong(key);
        }
        throw new Exception("Not found long value in configs with key: " ~ key);
    }

    override bool setLong(string key, long value)
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.setLong(key, value);
        }

        if (isThrowOnFailSetter)
        {
            import std.conv : text;

            throw new Exception(text("Not found config for key ", key, " and long value ", value));
        }
        return false;
    }

    override double getDouble(string key) const
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.getDouble(key);
        }
        throw new Exception("Not found double value in configs with key: " ~ key);
    }

    override bool setDouble(string key, double value)
    {
        if (auto config = searchConfigOrNull(key))
        {
            return config.setDouble(key, value);
        }
        
        if (isThrowOnFailSetter)
        {
            import std.conv : text;

            throw new Exception(text("Not found config for key ", key, " and double value ", value));
        }
        return false;
    }

    inout(Config[]) configs() inout => _configs;

    override immutable(ConfigAggregator) idup() const
    {
        immutable(Config)[] newConfigs;
        foreach (c; configs)
        {
            newConfigs ~= c.idup;
        }
        return new immutable ConfigAggregator(newConfigs);
    }

    override string toText() const
    {
        import std.array : appender;

        auto builder = appender!string;
        foreach (config; _configs)
        {
            builder ~= config.toText;
        }
        return builder.data;
    }
}

unittest
{
    import std.exception : assertThrown;

    //TODO add simple implementation
    import api.core.configs.keyvalues.aa_const_config : AAConstConfig;

    enum keyName = "key";

    immutable ca = new immutable ConfigAggregator([]);
    assert(!ca.hasKey(keyName));
    assertThrown(ca.getNotEmptyString(keyName));
}
