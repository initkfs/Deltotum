module deltotum.core.configs.config_aggregator;

import deltotum.core.configs.config : Config;
import deltotum.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import deltotum.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

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

        throw new ConfigValueNotFoundException("Not found config for key: " ~ key);
    }

    override Nullable!bool getBool(string key) const
    {
        return searchConfigByKey(key).getBool(key);
    }

    override void setBool(string key, bool value)
    {
        searchConfigByKey(key).setBool(key, value);
    }

    override Nullable!string getString(string key) const
    {
        return searchConfigByKey(key).getString(key);
    }

    override void setString(string key, string value)
    {
        searchConfigByKey(key).setString(key, value);
    }

    override Nullable!long getLong(string key) const
    {
        return searchConfigByKey(key).getLong(key);
    }

    override void setLong(string key, long value)
    {
        searchConfigByKey(key).setLong(key, value);
    }

    override Nullable!double getDouble(string key) const
    {
        return searchConfigByKey(key).getDouble(key);
    }

    override void setDouble(string key, double value)
    {
        searchConfigByKey(key).setDouble(key, value);
    }

    inout(Config[]) configs() inout
    {
        return _configs;
    }
}

unittest
{
    //TODO add simple implementation
    import deltotum.core.configs.environments.env_config : EnvConfig;

    immutable ca = new immutable ConfigAggregator([new immutable EnvConfig]);
    assert(!ca.containsKey("___not_key"));
}
