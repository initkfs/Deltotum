module api.core.configs.keyvalues.properties.property_config;

import api.core.configs.keyvalues.config : Config;

import std.container.slist : SList;
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

            inout(Line) dup() inout
            {
                return Line(line, key, value, isEmpty);
            }
        }

        Line*[string] keyIndex;
        Line*[] lines;
    }

    this(string configPath = null) pure @safe
    {
        this._configPath = configPath;
    }

    this(string configPath,
        immutable Line*[string] keyIndex,
        immutable(Line*)[] lines) immutable pure @safe
    {
        this._configPath = configPath;
        this.keyIndex = keyIndex;
        this.lines = lines;
    }

    override bool load()
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
        return load(configText);
    }

    bool load(string configText)
    {
        import std.array : split, appender;
        import std.algorithm : map, canFind;
        import std.string : strip;

        clear;

        if (configText.length == 0)
        {
            return false;
        }

        auto lineBuilder = appender(&lines);

        foreach (line; configText.split(lineSeparator))
        {
            if (!line.canFind(valueSeparator))
            {
                lineBuilder ~= new Line(line, null, null, true);
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
            lineBuilder ~= newLine;
        }

        keyIndex.rehash;

        return lines.length > 0;
    }

    override bool save()
    {
        if (!_configPath)
        {
            return false;
        }

        import std.file : write;

        auto configString = toString;
        write(_configPath, configString);
        return true;
    }

    override bool clear()
    {
        lines = null;
        keyIndex = null;
        return true;
    }

    override bool hasKey(string key) const
    {
        return (key in keyIndex) !is null;
    }

    protected inout(Line**) containsLinePtr(string key) inout
    {
        import std.exception : enforce;

        enforce(key && key.length > 0, "Config key must not be empty");

        auto keyPtr = key in keyIndex;
        assert(keyPtr);

        return keyPtr.to!(inout(Line**));
    }

    T getValue(T)(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        //isThrowOnNotExistentKey?
        if (!valuePtr)
        {
            throw new Exception("Not found value for key: " ~ key);
        }
        return getValue!T(valuePtr);
    }

    protected T getValue(T)(const(Line**) linePtr) const
    {
        assert(linePtr);
        return (*linePtr).value.to!T;
    }

    bool setValue(T)(string key, T value)
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            return false;
        }
        (*valuePtr).value = value.to!string;
        return true;
    }

    override bool getBool(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found boolean value in config with key: " ~ key);
        }
        return getValue!bool(valuePtr);
    }

    override bool setBool(string key, bool value) => setValue(key, value);

    override string getString(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found string value in config with key: " ~ key);
        }

        return getValue!string(valuePtr);
    }

    override bool setString(string key, string value) => setValue(key, value);

    override int getInt(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found integer value in config with key: " ~ key);
        }
        return getValue!int(valuePtr);
    }

    override bool setInt(string key, int value) => setValue(key, value);

    override long getLong(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found long value in config with key: " ~ key);
        }
        return getValue!long(valuePtr);
    }

    override bool setLong(string key, long value) => setValue(key, value);

    override float getFloat(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found float value in config with key: " ~ key);
        }

        return getValue!float(valuePtr);
    }

    override bool setFloat(string key, float value) => setValue(key, value);

    override double getDouble(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            throw new Exception(
                "Not found double value in config with key: " ~ key);
        }

        return getValue!double(valuePtr);
    }

    override bool setDouble(string key, double value) => setValue(key, value);

    T[] getList(T)(string key) const
    {
        auto valuePtr = containsLinePtr(key);
        if (!valuePtr)
        {
            if (isThrowOnNotExistentKey)
            {
                throw new Exception(
                    "Not found array in config with key: " ~ key);
            }
            else
            {
                return [];
            }
        }

        import std.algorithm : split;

        typeof(return) list = (getValue!string(valuePtr)).split.to!(T[]);

        return list;
    }

    bool hasConfigPath() const nothrow pure @safe => _configPath.length > 0;

    string configPath() const nothrow pure @safe
    in (_configPath.length > 0)
    {
        return _configPath;
    }

    override string toText() const
    {
        if (lines.length == 0)
        {
            return "";
        }

        import std.array : appender;

        auto result = appender!string;
        const size_t lastLineIndex = lines.length - 1;
        foreach (i, line; lines)
        {
            if (line.isEmpty)
            {
                //TODO last line?
                result ~= line.line;
                if (i != lastLineIndex)
                {
                    result ~= lineSeparator;
                }
                continue;
            }
            result ~= line.key;
            result ~= valueSeparator;
            result ~= line.value;
            if (i != lastLineIndex)
            {
                result ~= lineSeparator;
            }
        }

        return result[];
    }

    override string toString() const
    {
        return toText;
    }

    override immutable(PropertyConfig) idup() const
    {
        immutable(Line*)[] newLines;
        foreach (l; lines)
        {
            newLines ~= new immutable Line(l.line, l.key, l.value, l.isEmpty);
        }

        Line*[string] newKeyIndex;
        foreach (key, l; keyIndex)
        {
            newKeyIndex[key] = new Line(l.line, l.key, l.value, l.isEmpty);
        }
        import std.exception : assumeUnique;

        immutable immNewKeyIndex = newKeyIndex.assumeUnique;

        immutable config = new immutable PropertyConfig(_configPath, immNewKeyIndex, newLines);
        return config;
    }
}

unittest
{
    //Spaces are not preserved
    string configText =
        "value1=1
//comment
value2=random text

value3=2.5
value4=true";
    auto config = new PropertyConfig;

    bool isEmptyLoad = config.load("");
    assert(!isEmptyLoad);

    bool isLoad = config.load(configText);
    assert(isLoad);

    assert(config.lines.length == 6);

    auto toStringResult = config.toString;
    import std.conv : text;

    assert(toStringResult.length == configText.length, text("Expected: ", configText.length, " received: ", toStringResult
            .length));

    assert(config.toString == configText, text("==>", toStringResult, "<=="));

    assert(config.hasKey("value1"));
    assert(config.hasKey("value2"));
    assert(config.hasKey("value3"));
    assert(config.hasKey("value4"));

    import std.conv : to;

    auto val1 = config.getLong("value1");
    assert(val1 == 1, val1.to!string);

    auto val3f = config.getFloat("value3");
    assert(val3f == 2.5, val3f.to!string);

    auto val3 = config.getDouble("value3");
    assert(val3 == 2.5, val3.to!string);

    auto val4 = config.getBool("value4");
    assert(val4 == true);

    bool isSet1 = config.setValue("value1", 2);
    assert(isSet1);
    bool isSet2 = config.setValue("value3", 10.5);
    assert(isSet2);
    bool isSet3 = config.setValue("value4", false);
    assert(isSet3);

    auto longV1 = config.getLong("value1");
    assert(longV1 == 2, longV1.to!string);

    auto fV3 = config.getFloat("value3");
    assert(fV3 == 10.5, fV3.to!string);

    auto dV3 = config.getDouble("value3");
    assert(dV3 == 10.5, dV3.to!string);

    auto bV4 = config.getBool("value4");
    assert(bV4 == false);

    immutable immConfig = config.idup;
    assert(immConfig.hasKey("value1"));

    auto immVal1 = config.getLong("value1");
    assert(immVal1 == 2, immVal1.to!string);

    auto immVal3 = config.getDouble("value3");
    assert(immVal3 == 10.5, immVal3.to!string);
}
