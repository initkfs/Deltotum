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
        Config[] configs;
    }

    this(Config[] configs)
    {
        this.configs = configs;
    }

    override void load()
    {
        foreach (config; configs)
        {
            config.load;
        }
    }

    override void save()
    {
        foreach (config; configs)
        {
            config.save;
        }
    }

    override bool containsKey(string key)
    {
        foreach (Config config; configs)
        {
            if (config.containsKey(key))
            {
                return true;
            }
        }
        return false;
    }

    Config searchConfigByKey(string key)
    {
        foreach (Config config; configs)
        {
            if (config.containsKey(key))
            {
                return config;
            }
        }

        throw new ConfigValueNotFoundException("Not found config for key: " ~ key);
    }

    override bool getBool(string key)
    {
        return searchConfigByKey(key).getBool(key);
    }

    override void setBool(string key, bool value)
    {
        searchConfigByKey(key).setBool(key, value);
    }

    override string getString(string key)
    {
        return searchConfigByKey(key).getString(key);
    }

    override void setString(string key, string value)
    {
        searchConfigByKey(key).setString(key, value);
    }

    override long getLong(string key)
    {
        return searchConfigByKey(key).getLong(key);
    }

    override void setLong(string key, long value)
    {
        searchConfigByKey(key).setLong(key, value);
    }

    override double getDouble(string key)
    {
        return searchConfigByKey(key).getDouble(key);
    }

    override void setDouble(string key, double value)
    {
        searchConfigByKey(key).setDouble(key, value);
    }
}
