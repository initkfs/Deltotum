module deltotum.core.configs.config;

import deltotum.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import deltotum.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

/**
 * Authors: initkfs
*/
abstract class Config
{
    abstract
    {
        void load();
        void save();

        bool containsKey(string key);

        bool getBool(string key);
        void setBool(string key, bool value);

        string getString(string key);
        void setString(string key, string value);

        long getLong(string key);
        void setLong(string key, long value);

        double getDouble(string key);
        void setDouble(string key, double value);
    }

    long getPositiveLong(string key)
    {
        long value = getLong(key);
        if (value <= 0)
        {
            import std.format : format;

            throw new ConfigValueIncorrectException(format(
                    "Expected positive long value from config with key '%s', but received %s", key, value));
        }
        return value;
    }

    void setPositiveLong(string key, long value)
    {
        if (value <= 0)
        {
            import std.format : format;

            throw new ConfigValueIncorrectException(format(
                    "Expected positive long value for config with key '%s', but received %s", key, value));
        }
        setLong(key, value);
    }

    double getFiniteDouble(string key)
    {
        double val = getDouble(key);

        import std.math.traits : isFinite;

        if (!isFinite(val))
        {
            import std.format : format;

            throw new ConfigValueIncorrectException(format(
                    "Expected finite double from config with key '%s', but received %s", key, val));
        }
        return val;
    }

    void setFiniteDouble(string key, double value)
    {
        import std.math.traits : isFinite;

        if (!isFinite(value))
        {
            import std.format : format;

            throw new ConfigValueIncorrectException(format(
                    "Expected finite double for config with key '%s', but received %s", key, value));
        }
        setDouble(key, value);
    }

    string getNotEmptyString(string key)
    {
        const string value = getString(key);
        if (value.length == 0)
        {
            throw new ConfigValueIncorrectException(
                "Received empty string value from config with key: " ~ key);
        }
        return value;
    }

    void setNotEmptyString(string key, string value)
    {
        import std.string : strip;

        if (value.strip.length == 0)
        {
            throw new ConfigValueIncorrectException(
                "String must not be empty for config with key: " ~ key);
        }
        setString(key, value);
    }
}
