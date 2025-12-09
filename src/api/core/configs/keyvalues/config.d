module api.core.configs.keyvalues.config;

/**
 * Authors: initkfs
*/
abstract class Config
{
    abstract
    {
        bool load();
        bool save();
        bool clear();
        string toText() const;

        bool hasKey(const string key) const;

        bool getBool(string key) const;
        bool setBool(string key, bool value);

        string getString(string key) const;
        bool setString(string key, string value);

        int getInt(string key) const;
        bool setInt(string key, int value);

        long getLong(string key) const;
        bool setLong(string key, long value);

        float getFloat(string key) const;
        bool setFloat(string key, float value);

        double getDouble(string key) const;
        bool setDouble(string key, double value);

        immutable(Config) idup() const;
    }

    long getPositiveLong(string key) const
    {
        auto value = getLong(key);
        if (value <= 0)
        {
            import std.format : format;

            throw new Exception(format(
                    "Expected positive long value from config with key '%s', but received %s", key, value));
        }

        return value;
    }

    bool setPositiveLong(string key, long value)
    {
        if (value <= 0)
        {
            import std.format : format;

            throw new Exception(format(
                    "Expected positive long value for config with key '%s', but received %s", key, value));
        }
        return setLong(key, value);
    }

    double getFiniteDouble(string key) const
    {
        auto value = getDouble(key);
        import std.math.traits : isFinite;

        if (!isFinite(value))
        {
            import std.format : format;

            throw new Exception(format(
                    "Expected finite double value from config with key '%s', but received %s", key, value));
        }

        return value;
    }

    bool setFiniteDouble(string key, double value)
    {
        import std.math.traits : isFinite;

        if (!isFinite(value))
        {
            import std.format : format;

            throw new Exception(format(
                    "Expected finite double for config with key '%s', but received %s", key, value));
        }
        return setDouble(key, value);
    }

    float getFiniteFloat(string key) const
    {
        auto value = getFloat(key);
        import std.math.traits : isFinite;

        if (!isFinite(value))
        {
            import std.format : format;

            throw new Exception(format(
                    "Expected finite float value from config with key '%s', but received %s", key, value));
        }

        return value;
    }

    bool setFiniteFloat(string key, float value)
    {
        import std.math.traits : isFinite;

        if (!isFinite(value))
        {
            import std.format : format;

            throw new Exception(format(
                    "Expected finite float for config with key '%s', but received %s", key, value));
        }
        return setFloat(key, value);
    }

    string getNotEmptyString(string key) const
    {
        auto value = getString(key);
        if (value.length == 0)
        {
            throw new Exception(
                "Received empty string value from config with key: " ~ key);
        }
        return value;
    }

    bool setNotEmptyString(string key, string value)
    {
        import std.string : strip;

        if (value.strip.length == 0)
        {
            throw new Exception(
                "String must not be empty for config with key: " ~ key);
        }
        return setString(key, value);
    }
}
