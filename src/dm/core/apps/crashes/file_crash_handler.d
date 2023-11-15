module dm.core.apps.crashes.file_crash_handler;

import dm.core.apps.crashes.crash_handler : CrashHandler;

import std.datetime.systime : Clock, SysTime;

/**
 * Authors: initkfs
 */
class FileCrashHandler : CrashHandler
{
    string crashDir;

    this(string crashDir) pure @safe
    {
        import std.exception: enforce;

        enforce(crashDir.length > 0, "Crash directory must not be empty path");

        this.crashDir = crashDir;
    }

    string createCrashName(in SysTime time = Clock.currTime) inout @safe
    {
        import std.datetime.systime : Clock, SysTime;
        import std.datetime.timezone : UTC;
        import std.format : format;
        import std.array : replace;

        immutable fileName = format("crash_local-%s_utc-%s.txt",
            time.toISOExtString(), time.toUTC.toISOExtString()).replace(":", "_");
        return fileName;
    }

    string createCrashInfo(Throwable t, string message = "") inout 
    {
        import std.array : appender;

        auto content = appender!string;
        if (message.length > 0)
        {
            content.put(message);
        }

        immutable errorInfo = t ? t.toString : "Throwable from application is null.";
        content.put(errorInfo);

        return content.data;
    }

    override void acceptCrash(Throwable t, string message = "") inout 
    {
        import std.path : buildPath;
        import std.file : exists, write;

        immutable string crashFileName = createCrashName();
        immutable string crashContent = createCrashInfo(t, message);
        immutable string crashFile = buildPath(crashDir, crashFileName);

        if (crashFile.exists)
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
    import std.datetime.timezone : UTC;
    import std.datetime.date : DateTime;

    immutable fch = new FileCrashHandler("/");
    immutable st = SysTime(DateTime(2023, 1, 1, 11, 30, 10), UTC());
    immutable crashName = fch.createCrashName(st);
    assert(crashName == "crash_local-2023-01-01T11_30_10Z_utc-2023-01-01T11_30_10Z.txt");

    immutable crashInfo = fch.createCrashInfo(new Exception("ex"));
    assert(crashInfo.length > 0);
}
