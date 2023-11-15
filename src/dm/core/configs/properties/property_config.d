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
    //private
    //{
        string configPath;

        struct Line
        {
            string line;
            string key;
            string value;
            bool isEmpty;
        }

        Line*[string] keyIndex;
        Line*[] lines;
    //}

    this(string configPath = null) pure @safe
    {
        this.configPath = configPath;
    }

    override void load()
    {
        import std.exception : enforce;
        import std.file : exists, isFile;

        if (!configPath.exists)
        {
            throw new Exception("Config path does not exist: " ~ configPath);
        }

        if (!configPath.isFile)
        {
            throw new Exception("Config path is not a file: " ~ configPath);
        }

        import std.file : readText;

        auto configText = configPath.readText;
        load(configText);
    }

    void load(string configText)
    {
        import std.array : split;
        import std.algorithm : map, canFind;
        import std.string: strip;

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
        if (!configPath)
        {
            //TODO return bool
            return;
        }
        import std.file : write;

        auto configString = toString;
        write(configPath, configString);
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

    void setValue(T)(string key, T value)
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found config key: " ~ key);
        }
        keyIndex[key].value = value.to!string;
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

        auto str = getValue!string(key);
        return Nullable!string(str);
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
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found array in config with key: " ~ key);
        }

        import std.algorithm : split;

        typeof(return) list = getString(key).split.to!(T[]);

        return list;
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
