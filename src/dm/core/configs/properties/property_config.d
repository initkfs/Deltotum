module dm.core.configs.properties.property_config;

import dm.core.configs.config : Config;
import dm.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import dm.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.typecons : Nullable;
import std.conv : to;

/**
 * Authors: initkfs
 */
class PropertyConfig : Config
{
    string lineSeparator = "\n";
    string valueSeparator = "=";
    private
    {
        string _configPath;

        struct Line
        {
            string line;
            string key;
            string value;
            bool isEmpty;
        }

        Line*[string] keyIndex;
        Line*[] lines;
    }

    this(string configPath = null) pure @safe
    {
        this._configPath = configPath;
    }

    override void load()
    {
        import std.exception : enforce;
        import std.file : exists, isFile;

        if (_configPath.length == 0)
        {
            throw new Exception("Config path is empty");
        }

        if (!_configPath.exists)
        {
            throw new Exception("Config path does not exist: " ~ _configPath);
        }

        if (!_configPath.isFile)
        {
            throw new Exception("Config path is not a file: " ~ _configPath);
        }

        import std.file : readText;

        auto configText = _configPath.readText;
        load(configText);
    }

    void load(string configText)
    {
        import std.array : split;
        import std.algorithm : map, canFind;
        import std.string : strip;

        foreach (line; configText.split(lineSeparator))
        {
            if (!line.canFind(valueSeparator))
            {
                lines ~= new Line(line, null, null, true);
                continue;
            }

            //TODO remove array allocation
            auto words = line.split(valueSeparator);
            if (words.length != 2)
            {
                throw new Exception("Invalid line from config received: " ~ line.to!string);
            }

            auto key = words[0].strip;
            auto value = words[1].strip;
            auto newLine = new Line(line, key, value);
            keyIndex[key] = newLine;
            lines ~= newLine;
        }
    }

    override void save()
    {
        if (!_configPath)
        {
            //TODO return bool
            return;
        }
        import std.file : write;

        auto configString = toString;
        write(_configPath, configString);
    }

    override bool containsKey(string key) const
    {
        import std.exception : enforce;

        enforce(key !is null, "Config key must not be null");
        enforce(key.length > 0, "Config key must not be empty");

        const bool isContainsKey = (key in keyIndex) !is null;
        return isContainsKey;
    }

    T getValue(T)(string key) const
    {
        return keyIndex[key].value.to!T;
    }

    bool setValue(T)(string key, T value)
    {
        if (!containsKey(key))
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found config key: " ~ key);
            }
            else
            {
                return false;
            }
        }
        keyIndex[key].value = value.to!string;
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

        auto str = getValue!string(key);
        return Nullable!string(str);
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
        if (!containsKey(key))
        {
            if (isThrowOnNotExistentKey)
            {
                throw new ConfigValueNotFoundException(
                    "Not found array in config with key: " ~ key);
            }
            else
            {
                return [];
            }
        }

        import std.algorithm : split;

        typeof(return) list = getString(key).split.to!(T[]);

        return list;
    }

    bool hasConfigPath() const nothrow pure @safe
    {
        return _configPath.length > 0;
    }

    string configPath() const nothrow pure @safe
    in(_configPath.length > 0)
    {
        return _configPath;
    }

    override string toString() const
    {
        if (lines.length == 0)
        {
            return "";
        }

        import std.array : appender;

        auto result = appender!string;
        foreach (line; lines)
        {
            if (line.isEmpty)
            {
                //TODO last line?
                result ~= line.line;
                result ~= lineSeparator;
                continue;
            }
            result ~= line.key;
            result ~= valueSeparator;
            result ~= line.value;
            result ~= lineSeparator;
        }

        return result[];
    }
}

unittest
{
    string configText =
        "value1 = 1
//comment
value2=random text

value3=2.5
value4=true";
    auto config = new PropertyConfig;
    config.load(configText);

    assert(config.lines.length == 6);

    assert(config.getLong("value1") == 1);
    assert(config.getDouble("value3") == 2.5);
    assert(config.getBool("value4") == true);

    config.setValue("value1", 2);
    config.setValue("value3", 10.5);
    config.setValue("value4", false);

    assert(config.getLong("value1") == 2);
    assert(config.getDouble("value3") == 10.5);
    assert(config.getBool("value4") == false);
}
