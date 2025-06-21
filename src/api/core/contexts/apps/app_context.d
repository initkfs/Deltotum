module api.core.contexts.apps.app_context;

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

    const nothrow pure @safe
    {
        string workDir() => _workDir;
        string dataDir() => _dataDir;
        string userDir() => _userDir;
    }

    immutable(AppContext) idup()
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

    assert(context.dataDir.length == 0);
    assert(context.userDir.length == 0);
    assert(context.workDir.length == 0);
}
