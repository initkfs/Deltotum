module dm.core.apps.crashes.file_crash_handler;

import dm.core.apps.crashes.time_crash_handler : TimeCrashHandler;

/**
 * Authors: initkfs
 */
class FileCrashHandler : TimeCrashHandler
{
    string crashDir;
    string fileExtension;

    bool appendIfFileExists = true;

    this(string crashDir, string fileExtension = ".txt") pure @safe
    {
        import std.exception : enforce;

        enforce(crashDir.length > 0, "Crash directory must not be empty path");

        this.crashDir = crashDir;
        this.fileExtension = fileExtension;
    }

    string createCrashFileName() inout @safe
    {
        return createCrashFileName(createCrashName);
    }

    string createCrashFileName(string crashName) inout @safe
    {
        assert(crashName.length > 0);

        auto fileName = crashName;
        assert(fileName.length > 0);

        enum extSep = '.';

        fileName ~= (fileExtension.length > 0 && fileExtension[0] != extSep) ? (
            extSep ~ fileExtension) : fileExtension;

        return fileName;
    }

    string buldCrashFilePath(string crashFile) inout @safe
    {
        return buldCrashFilePath(crashDir, crashFile);
    }

    string buldCrashFilePath(string crashFileDir, string crashFile) inout pure @safe
    {
        import std.path : buildPath;

        immutable filePath = buildPath(crashFileDir, crashFile);
        return filePath;
    }

    override void acceptCrash(Throwable t, const(char)[] message = "") inout
    {
        import std.file : exists, write;
        import std.file: isFile;

        immutable string crashFileName = createCrashFileName;
        immutable string crashContent = createCrashInfo(t, message);

        immutable string crashFile = buldCrashFilePath(crashFileName);

        if (crashFile.exists && crashFile.isFile && appendIfFileExists)
        {
            import std.file : append;

            append(crashFile, crashContent);
            return;
        }

        write(crashFile, crashContent);
    }
}

unittest
{
    auto crashHandler = new FileCrashHandler("/dir/");

    auto crashName = crashHandler.createCrashFileName("file.");
    assert(crashName.length > 0);
    assert(crashName == "file..txt", crashName);

    auto path1 = crashHandler.buldCrashFilePath("/dir/", "file.txt");
    assert(path1 == "/dir/file.txt", path1);

    auto defaultPath1 = crashHandler.buldCrashFilePath("file.txt");
    assert(defaultPath1 == "/dir/file.txt", defaultPath1);

}
