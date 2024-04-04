module dm.core.configs.config;

import dm.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import dm.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.typecons : Nullable;

/**
 * Authors: initkfs
*/
abstract class Config
{
    bool isThrowOnNotExistentKey = true;
    bool isThrowOnSetValueNotExistentKey = true;

    abstract
    {
        bool load();
        bool save();
        bool clear();
        string toText() const;

        bool containsKey(const string key) const;

        Nullable!bool getBool(string key) const;
        bool setBool(string key, bool value);

        Nullable!string getString(string key) const;
        bool setString(string key, string value);

        Nullable!long getLong(string key) const;
        bool setLong(string key, long value);

        Nullable!double getDouble(string key) const;
        bool setDouble(string key, double value);

        immutable(Config) idup() const;
    }

    Nullable!long getPositiveLong(string key) const
    {
        auto mustBeValue = getLong(key);
        if (!mustBeValue.isNull)
        {
            const long value = mustBeValue.get;

            if (value <= 0)
            {
                import std.format : format;

                throw new ConfigValueIncorrectException(format(
                        "Expected positive long value from config with key '%s', but received %s", key, value));
            }
        }

        return mustBeValue;
    }

    bool setPositiveLong(string key, long value)
    {
        if (value <= 0)
        {
            import std.format : format;

            throw new ConfigValueIncorrectException(format(
                    "Expected positive long value for config with key '%s', but received %s", key, value));
        }
        return setLong(key, value);
    }

    Nullable!double getFiniteDouble(string key) const
    {
        auto mustBeValue = getDouble(key);
        if (!mustBeValue.isNull)
        {
            double val = mustBeValue.get;

            import std.math.traits : isFinite;

            if (!isFinite(val))
            {
                import std.format : format;

                throw new ConfigValueIncorrectException(format(
                        "Expected finite double from config with key '%s', but received %s", key, val));
            }
        }

        return mustBeValue;
    }

    bool setFiniteDouble(string key, double value)
    {
        import std.math.traits : isFinite;

        if (!isFinite(value))
        {
            import std.format : format;

            throw new ConfigValueIncorrectException(format(
                    "Expected finite double for config with key '%s', but received %s", key, value));
        }
        return setDouble(key, value);
    }

    Nullable!string getNotEmptyString(string key) const
    {
        auto mustBeString = getString(key);
        if (!mustBeString.isNull)
        {
            const string value = mustBeString.get;
            if (value.length == 0)
            {
                throw new ConfigValueIncorrectException(
                    "Received empty string value from config with key: " ~ key);
            }
        }
        return mustBeString;
    }

    bool setNotEmptyString(string key, string value)
    {
        import std.string : strip;

        if (value.strip.length == 0)
        {
            throw new ConfigValueIncorrectException(
                "String must not be empty for config with key: " ~ key);
        }
        return setString(key, value);
    }
}
