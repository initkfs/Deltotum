module api.core.contexts.apps.app_context;

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

    Nullable!string workDir() const nothrow pure @safe
    {
        return _workDir ? Nullable!string(_workDir) : Nullable!string.init;
    }

    Nullable!string dataDir() const nothrow pure @safe
    {
        return _dataDir ? Nullable!string(_dataDir) : Nullable!string.init;
    }

    Nullable!string userDir() const nothrow pure @safe
    {
        return _userDir ? Nullable!string(_userDir) : Nullable!string.init;
    }

    immutable(AppContext) idup() immutable
    {
        return new immutable AppContext(_workDir, _dataDir, _userDir, isDebug, isSilent);
    }

    void exit(int code) const
    {
        import StdcLib = core.stdc.stdlib;

        StdcLib.exit(code);
    }
}

unittest
{
    immutable context = new immutable AppContext;

    assert(context.dataDir.isNull);
    assert(context.userDir.isNull);
    assert(context.workDir.isNull);
}
