module api.core.configs.keyvalues.null_config;

import api.core.configs.keyvalues.config : Config;

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

    override bool getBool(string key) const => false;
    override bool setBool(string key, bool value) const => false;

    override string getString(string key) const => null;
    override bool setString(string key, string value) const => false;

    override int getInt(string key) const => 0;
    override bool setInt(string key, int value) => false;

    override long getLong(string key) const => 0;
    override bool setLong(string key, long value) const => false;

    override double getDouble(string key) const => 0;
    override bool setDouble(string key, double value) const => false;

    override long getPositiveLong(string key) const => 1;
    override bool setPositiveLong(string key, long value) const => false;

    override float getFloat(string key) const => 0;
    override bool setFloat(string key, float value) const => false;

    override float getFiniteFloat(string key) const => 0;
    override bool setFiniteFloat(string key, float value) const => false;

    override double getFiniteDouble(string key) const => 0;
    override bool setFiniteDouble(string key, double value) const => false;

    override string getNotEmptyString(string key) const => "string";
    override bool setNotEmptyString(string key, string value) const => false;

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

    assert(!nc.getBool(key));
    assert(!nc.setBool(key, true));

    assert(nc.getString(key).length == 0);
    assert(!nc.setString(key, key));

    assert(nc.getLong(key) == 0);
    assert(!nc.setLong(key, 0));

    assert(nc.getFloat(key) == 0);
    assert(!nc.setFloat(key, 4.5));

    assert(nc.getDouble(key) == 0);
    assert(!nc.setDouble(key, 4.5));

    assert(nc.getPositiveLong(key) == 1);
    assert(!nc.setPositiveLong(key, -4));

    assert(nc.getFiniteDouble(key) == 0);
    assert(!nc.setFiniteDouble(key, double.nan));

    assert(nc.getNotEmptyString(key).length > 0);
    assert(!nc.setNotEmptyString(key, ""));
}
