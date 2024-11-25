module api.core.configs.keyvalues.null_config;

import api.core.configs.keyvalues.config : Config;

import std.typecons : Nullable;

/**
 * Authors: initkfs
*/
class NullConfig : Config
{

    override bool load() const
    {
        return false;
    }

    override bool save() const
    {
        return false;
    }

    override bool clear() const
    {
        return false;
    }

    override bool hasKey(const string key) const
    {
        return false;
    }

    override Nullable!bool getBool(string key) const
    {
        return Nullable!bool.init;
    }

    override bool setBool(string key, bool value) const
    {
        return false;
    }

    override Nullable!string getString(string key) const
    {
        return Nullable!string.init;
    }

    override bool setString(string key, string value) const
    {
        return false;
    }

    override Nullable!int getInt(string key) const
    {
        return Nullable!int.init;
    }

    override bool setInt(string key, int value)
    {
        return false;
    }

    override Nullable!long getLong(string key) const
    {
        return Nullable!long.init;
    }

    override bool setLong(string key, long value) const
    {
        return false;
    }

    override Nullable!double getDouble(string key) const
    {
        return Nullable!double.init;
    }

    override bool setDouble(string key, double value) const
    {
        return false;
    }

    override Nullable!long getPositiveLong(string key) const
    {
        return Nullable!long.init;
    }

    override bool setPositiveLong(string key, long value) const
    {
        return false;
    }

    override Nullable!double getFiniteDouble(string key) const
    {
        return Nullable!double.init;
    }

    override bool setFiniteDouble(string key, double value) const
    {
        return false;
    }

    override Nullable!string getNotEmptyString(string key) const
    {
        return Nullable!string.init;
    }

    override bool setNotEmptyString(string key, string value) const
    {
        return false;
    }

    override string toText() const
    {
        return "";
    }

    override immutable(NullConfig) idup() const
    {
        return new immutable NullConfig;
    }
}

unittest
{
    immutable nc = new immutable NullConfig;

    enum key = "key";

    assert(!nc.load);
    assert(!nc.save);
    assert(!nc.clear);
    assert(!nc.hasKey(key));

    assert(nc.getBool(key).isNull);
    assert(!nc.setBool(key, true));

    assert(nc.getString(key).isNull);
    assert(!nc.setString(key, key));

    assert(nc.getLong(key).isNull);
    assert(!nc.setLong(key, 0));

    assert(nc.getDouble(key).isNull);
    assert(!nc.setDouble(key, 4.5));

    assert(nc.getPositiveLong(key).isNull);
    assert(!nc.setPositiveLong(key, -4));

    assert(nc.getFiniteDouble(key).isNull);
    assert(!nc.setFiniteDouble(key, double.nan));

    assert(nc.getNotEmptyString(key).isNull);
    assert(!nc.setNotEmptyString(key, ""));
}
