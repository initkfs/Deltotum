module dm.core.configs.environments.env_config;

import dm.core.configs.config : Config;
import dm.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import dm.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.typecons : Nullable;
import std.process: environment;
import std.conv: to;

/**
 * Authors: initkfs
 */
class EnvConfig : Config
{
    override void load()
    {
        
    }

    override void save()
    {
        
    }

    override bool containsKey(string key) const
    {
        return key in environment;
    }

    T getValue(T)(string key) const
    {
        return environment[key].to!T;
    }

    void setValue(T)(string key, T value)
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found config key in environment: " ~ key);
        }
        environment[key] = to!string(value);
    }

    override Nullable!bool getBool(string key) const
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found boolean value in config with key: " ~ key);
        }
        const bool value = getValue!bool(key);
        return Nullable!bool(value);
    }

    override void setBool(string key, bool value)
    {
        setValue(key, value);
    }

    override Nullable!string getString(string key) const
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found string value in config with key: " ~ key);
        }

        const strValue = getValue!string(key);
        return Nullable!string(strValue);
    }

    override void setString(string key, string value)
    {
        setValue(key, value);
    }

    override Nullable!long getLong(string key) const
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found integer value in config with key: " ~ key);
        }
        const long value = getValue!long(key);
        return Nullable!long(value);
    }

    override void setLong(string key, long value)
    {
        setValue(key, value);
    }

    override Nullable!double getDouble(string key) const
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found double value in config with key: " ~ key);
        }

        const double value = getValue!double(key);
        return Nullable!double(value);
    }

    override void setDouble(string key, double value)
    {
        setValue(key, value);
    }

    T[] getList(T)(string key) const
    {
        throw new Exception("Non supported yet");
    }
}
