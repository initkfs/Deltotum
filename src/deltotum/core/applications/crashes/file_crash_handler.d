module deltotum.core.applications.crashes.file_crash_handler;

import deltotum.core.applications.crashes.crash_handler : CrashHandler;

/**
 * Authors: initkfs
 */
class FileCrashHandler : CrashHandler
{
    string workDir;

    this(string workDir)
    {
        this.workDir = workDir;
    }

    string createCrashName()
    {
        import std.datetime.systime : Clock, SysTime;
        import std.datetime.timezone : UTC;
        import std.format : format;
        import std.array : replace;

        const SysTime dateTimeNow = Clock.currTime;
        const string fileName = format("crash_local-%s_utc-%s.txt",
            dateTimeNow.toISOExtString(), dateTimeNow.toUTC.toISOExtString()).replace(":", "_");
        return fileName;
    }

    override void acceptCrash(Throwable exFromApplication, string message = "")
    {
        import std.path : buildPath;
        import std.array : appender;
        import std.file : write;

        auto content = appender!string;
        if (message.length > 0)
        {
            content.put(message);
        }

        immutable errorInfo = exFromApplication !is null ? exFromApplication.toString
            : "Throwable from application is null.";
        content.put(errorInfo);

        const string crashFileName = createCrashName();
        const string crashFile = buildPath(workDir, crashFileName);

        write(crashFile, content.toString);
    }
}
