module deltotum.core.contexts.apps.app_context;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class AppContext
{
    bool isDebug;
    bool isSilent;

    private
    {
        string _workDir;
        string _dataDir;
        string _userDir;
    }

    this(string workDir = null, string dataDir = null, string userDir = null, bool isDebug = true, bool isSilent = false) pure @safe
    {
        _workDir = workDir;
        _dataDir = dataDir;
        _userDir = userDir;
        this.isDebug = isDebug;
        this.isSilent = isSilent;
    }

    this(string workDir = null, string dataDir = null, string userDir = null, bool isDebug = true, bool isSilent = false) immutable pure @safe
    {
        _workDir = workDir;
        _dataDir = dataDir;
        _userDir = userDir;
        this.isDebug = isDebug;
        this.isSilent = isSilent;
    }

    Nullable!string workDir() const @nogc nothrow pure @safe
    {
        return Nullable!string(_workDir);
    }

    Nullable!string dataDir() const @nogc nothrow pure @safe
    {
        return Nullable!string(_dataDir);
    }

    Nullable!string userDir() const @nogc nothrow pure @safe
    {
        return Nullable!string(_userDir);
    }
}
