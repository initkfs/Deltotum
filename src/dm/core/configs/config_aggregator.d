module dm.core.configs.config_aggregator;

import dm.core.configs.config : Config;
import dm.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import dm.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.typecons : Nullable;

/**
 * Authors: initkfs
*/
class ConfigAggregator : Config
{
    private
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

    override void load()
    {
        foreach (config; _configs)
        {
            config.load;
        }
    }

    override void save()
    {
        foreach (config; _configs)
        {
            config.save;
        }
    }

    override bool containsKey(string key) const
    {
        foreach (config; _configs)
        {
            if (config.containsKey(key))
            {
                return true;
            }
        }
        return false;
    }

    inout(Config) searchConfigByKey(string key) inout
    {
        foreach (config; _configs)
        {
            if (config.containsKey(key))
            {
                return config;
            }
        }

        if (isThrowOnNotExistentKey)
        {
            throw new ConfigValueNotFoundException("Not found config for key: " ~ key);
        }

        return null;
    }

    override Nullable!bool getBool(string key) const
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.getBool(key);
        }
        return Nullable!bool.init;
    }

    override bool setBool(string key, bool value)
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.setBool(key, value);
        }

        if (isThrowOnSetValueNotExistentKey)
        {
            import std.conv : text;

            throw new ConfigValueIncorrectException(text("Not found config for key ", key, " and bool value ", value));
        }

        return false;
    }

    override Nullable!string getString(string key) const
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.getString(key);
        }
        return Nullable!string.init;
    }

    override bool setString(string key, string value)
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.setString(key, value);
        }

        if (isThrowOnSetValueNotExistentKey)
        {
            import std.conv : text;

            throw new ConfigValueIncorrectException(text("Not found config for key ", key, " and string value ", value));
        }

        return false;
    }

    override Nullable!long getLong(string key) const
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.getLong(key);
        }
        return Nullable!long.init;
    }

    override bool setLong(string key, long value)
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.setLong(key, value);
        }

        if (isThrowOnSetValueNotExistentKey)
        {
            import std.conv : text;

            throw new ConfigValueIncorrectException(text("Not found config for key ", key, " and long value ", value));
        }

        return false;
    }

    override Nullable!double getDouble(string key) const
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.getDouble(key);
        }
        return Nullable!double.init;
    }

    override bool setDouble(string key, double value)
    {
        if (auto config = searchConfigByKey(key))
        {
            return config.setDouble(key, value);
        }
        if (isThrowOnSetValueNotExistentKey)
        {
            import std.conv : text;

            throw new ConfigValueIncorrectException(text("Not found config for key ", key, " and double value ", value));
        }

        return false;
    }

    inout(Config[]) configs() inout
    {
        return _configs;
    }
}

unittest
{
    import std.exception : assertThrown;

    //TODO add simple implementation
    import dm.core.configs.environments.env_config : EnvConfig;

    enum keyName = "key";

    immutable ca = new immutable ConfigAggregator([]);
    assert(!ca.containsKey(keyName));
    assertThrown(ca.getNotEmptyString(keyName));

    auto cMut = new ConfigAggregator([]);

    assertThrown(cMut.getNotEmptyString(keyName));
    cMut.isThrowOnNotExistentKey = false;
    assert(cMut.getNotEmptyString(keyName).isNull);

    assertThrown(cMut.setString(keyName, "value"));
    cMut.isThrowOnSetValueNotExistentKey = false;
    assert(!cMut.setString(keyName, "value"));
}
