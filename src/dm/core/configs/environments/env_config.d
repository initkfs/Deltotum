module dm.core.configs.environments.env_config;

import dm.core.configs.config : Config;
import dm.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import dm.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.typecons : Nullable;
import std.process : environment;
import std.conv : to;

/**
 * Authors: initkfs
 * TODO remove code duplications
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

    bool setValue(T)(string key, T value)
    {
        if (!containsKey(key))
        {
            if (isThrowOnSetValueNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found config key in environment: " ~ key);
            }
            return false;
        }
        environment[key] = to!string(value);
        return true;
    }

    override Nullable!bool getBool(string key) const
    {
        if (!containsKey(key))
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found boolean value in config with key: " ~ key);
            }
            else
            {
                return Nullable!bool.init;
            }
        }
        const bool value = getValue!bool(key);
        return Nullable!bool(value);
    }

    override bool setBool(string key, bool value)
    {
        return setValue(key, value);
    }

    override Nullable!string getString(string key) const
    {
        if (!containsKey(key))
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found string value in config with key: " ~ key);
            }
            else
            {
                return Nullable!string.init;
            }
        }

        const strValue = getValue!string(key);
        return Nullable!string(strValue);
    }

    override bool setString(string key, string value)
    {
        return setValue(key, value);
    }

    override Nullable!long getLong(string key) const
    {
        if (!containsKey(key))
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found integer value in config with key: " ~ key);
            }
            else
            {
                return Nullable!long.init;
            }
        }
        const long value = getValue!long(key);
        return Nullable!long(value);
    }

    override bool setLong(string key, long value)
    {
        return setValue(key, value);
    }

    override Nullable!double getDouble(string key) const
    {
        if (!containsKey(key))
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found double value in config with key: " ~ key);
            }
            else
            {
                return Nullable!double.init;
            }
        }

        const double value = getValue!double(key);
        return Nullable!double(value);
    }

    override bool setDouble(string key, double value)
    {
        return setValue(key, value);
    }

    T[] getList(T)(string key) const
    {
        throw new Exception("Non supported yet");
    }
}
