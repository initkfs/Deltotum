module deltotum.core.configs.json.json_config;

import deltotum.core.configs.config : Config;
import deltotum.core.configs.exceptions.config_value_incorrect_exception : ConfigValueIncorrectException;
import deltotum.core.configs.exceptions.config_value_notfound_exception : ConfigValueNotFoundException;

import std.json : JSONValue;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class JsonConfig : Config
{
    private
    {
        JSONValue root;
        string configPath;
    }

    this(string configPath)
    {
        this.configPath = configPath;
    }

    override void load()
    {
        import std.exception : enforce;
        import std.file : exists, isFile;
        import std.json : parseJSON;

        if (!configPath.exists)
        {
            throw new Exception("Config path does not exist: " ~ configPath);
        }

        if (!configPath.isFile)
        {
            throw new Exception("Config path is not a file: " ~ configPath);
        }

        import std.file : readText;

        const jsonText = configPath.readText;
        if (jsonText.length == 0)
        {
            //error?
        }

        root = parseJSON(jsonText);
    }

    void load(string json)
    {
        import std.json : parseJSON;

        if (json.length == 0)
        {
            throw new Exception("JSON string must not be empty");
        }

        root = parseJSON(json);
    }

    override void save()
    {
        import std.stdio : File;

        string jsonString = toString;
        if (jsonString.length == 0)
        {
            throw new Exception("Config overwrite error: JSON string is empty");
        }
        auto configFile = File(configPath, "w");
        try
        {
            auto textWriter = configFile.lockingTextWriter;
            textWriter.put(jsonString);
        }
        finally
        {
            configFile.close();
        }
    }

    override bool containsKey(string key)
    {
        import std.exception : enforce;

        enforce(key !is null, "Config key must not be null");
        enforce(key.length > 0, "Config key must not be empty");

        const bool isContainsKey = (key in root) !is null;
        return isContainsKey;
    }

    T getValue(T)(string key)
    {
        return root[key].get!T;
    }

    void setValue(T)(string key, T value)
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found config key: " ~ key);
        }
        root[key] = value;
    }

    override Nullable!bool getBool(string key)
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

    override Nullable!string getString(string key)
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found string value in config with key: " ~ key);
        }

        const value = root[key];

        import std.json : JSONType;

        if (value.type != JSONType.string)
        {
            if (value.type == JSONType.null_)
            {
                return Nullable!string("");
            }

            import std.format : format;

            throw new ConfigValueIncorrectException(
                format("Value is not a string with key '%s': %s", key, value.type));
        }

        import std.string : strip;

        const strValue = value.str.strip;
        //TODO lowercase
        if (strValue == "null")
        {
            return Nullable!string("");
        }
        return Nullable!string(strValue);
    }

    override void setString(string key, string value)
    {
        setValue(key, value);
    }

    override Nullable!long getLong(string key)
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

    override Nullable!double getDouble(string key)
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

    T[] getList(T)(string key)
    {
        if (!containsKey(key))
        {
            throw new ConfigValueNotFoundException(
                "Not found array in config with key: " ~ key);
        }

        import std.json : JSONValue;

        JSONValue[] arr = root[key].array;

        import std.algorithm.iteration : map;
        import std.array : array;

        T[] result = arr.map!(v => v.get!T).array;
        return result;
    }

    override string toString() const
    {
        import std.json : toJSON;

        return toJSON(root, true);
    }
}

unittest
{
    import std.math.operations : isClose;

    const jsonStr = `{   
        "a": "foo",   
        "b": 56.23,   
        "c": true,
        "d": "",
        "e": "null",
        "f": null,
        "j": ["a", "b", "c"]
    }`;

    JsonConfig jsonConfig = new JsonConfig("");
    jsonConfig.load(jsonStr);

    assert(jsonConfig.getString("a") == "foo");
    assert(isClose(jsonConfig.getDouble("b"), 56.2299999999999));
    assert(jsonConfig.getBool("c").get);
    assert(jsonConfig.getString("d") == "");
    assert(jsonConfig.getString("e") == "");
    assert(jsonConfig.getString("f") == "");
    assert(jsonConfig.getList!string("j") == ["a", "b", "c"]);

    jsonConfig.setString("a", "    bar     ");
    jsonConfig.setDouble("b", 0.000000); //not 0
    jsonConfig.setValue("j", ["c"]);

    assert(jsonConfig.getString("a") == "bar");
    assert(jsonConfig.getDouble("b") == 0);
    assert(jsonConfig.getList!string("j") == ["c"]);
}
