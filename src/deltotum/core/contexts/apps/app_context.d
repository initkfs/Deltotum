module deltotum.core.contexts.apps.app_context;
/**
 * Authors: initkfs
 */
class AppContext
{
    const
    {
        string workingDir;
        string dataDir;
        string userDir;

        bool isDebug;
        bool isSilent;
    }

    this(const string workingDir, const string dataDir, const string userDir, const bool isDebug, const bool isSilent)
    {
        import std.string : strip;
        import std.exception : enforce;
        import std.file : isDir, exists;

        enforce(workingDir !is null, "Working directory must not be null");
        enforce(workingDir.strip.length > 0, "Working directory must not be empty");
        if (!workingDir.exists || !workingDir.isDir)
        {
            import std.format : format;
            import std.file : FileException;

            throw new FileException(format("Working directory is not a directory: %s",
                    workingDir));
        }

        enforce(dataDir !is null, "Data directory must not be null");
        enforce(dataDir.strip.length > 0, "Data directory must not be empty");
        if (!dataDir.exists || !dataDir.isDir)
        {
            import std.format : format;
            import std.file : FileException;

            throw new FileException(format("Data directory is not a directory: %s", dataDir));
        }

        enforce(userDir !is null, "User directory must not be null");
        enforce(userDir.strip.length > 0, "User directory must not be empty");

        this.workingDir = workingDir;
        this.dataDir = dataDir;
        this.userDir = userDir;
        
        this.isDebug = isDebug;
        this.isSilent = isSilent;
    }
}
