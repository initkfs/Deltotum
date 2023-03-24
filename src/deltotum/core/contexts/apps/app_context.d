module deltotum.core.contexts.apps.app_context;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class AppContext
{
    const
    {
        bool isDebug;
        bool isSilent;
    }

    private const
    {
        string _workingDir;
        string _dataDir;
        string _userDir;
    }

    this(const string workingDir = null, const string dataDir = null, const string userDir = null, const bool isDebug = true, const bool isSilent = false)
    {
        import std.string : strip;
        import std.exception : enforce;
        import std.file : isDir, exists;

        if (workingDir !is null)
        {
            enforce(workingDir.strip.length > 0, "Working directory must not be empty");
            if (!workingDir.exists || !workingDir.isDir)
            {
                import std.file : FileException;

                throw new FileException(
                    "Working directory does not exist or is not a directory: " ~
                        workingDir);
            }

            _workingDir = workingDir;
        }

        if (dataDir !is null)
        {
            enforce(dataDir.strip.length > 0, "Data directory must not be empty");
            if (!dataDir.exists || !dataDir.isDir)
            {
                import std.file : FileException;

                throw new FileException(
                    "Data directory does not exist or is not a directory: " ~ dataDir);
            }

            _dataDir = dataDir;
        }

        if (userDir !is null)
        {
            enforce(userDir.strip.length > 0, "User directory must not be empty");
            if (!userDir.exists || !userDir.isDir)
            {
                import std.file : FileException;

                throw new FileException(
                    "User directory does not exist or is not a directory: " ~ userDir);
            }
            _userDir = userDir;
        }

        this.isDebug = isDebug;
        this.isSilent = isSilent;
    }

    Nullable!string workingDir() const @nogc nothrow pure @safe
    {
        return Nullable!string(_workingDir);
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
