module app.core.apps.crashes.time_crash_handler;

import app.core.apps.crashes.crash_handler : CrashHandler;

import std.datetime.systime : Clock, SysTime;

/**
 * Authors: initkfs
 */
abstract class TimeCrashHandler : CrashHandler
{
    string createCrashName(in SysTime time = Clock.currTime) inout @safe
    {
        import std.datetime.systime : Clock, SysTime;
        import std.datetime.timezone : UTC;
        import std.format : format;
        import std.array : replace;

        immutable fileName = format("crash_local-%s_utc-%s",
            time.toISOExtString(), time.toUTC.toISOExtString()).replace(":", "_");
        return fileName;
    }

    string createCrashInfo(Throwable t, const(char)[] message = "") inout
    {
        import std.array : appender;

        auto content = appender!string;
        if (message.length > 0)
        {
            content.put(message);
            content.put(" ");
        }

        immutable errorInfo = t ? t.toString : "Throwable is null.";
        content.put(errorInfo);

        return content.data;
    }
}

unittest
{
    import std.datetime.timezone : UTC;
    import std.datetime.date : DateTime;

    const crHandler = new class TimeCrashHandler
    {
        override void acceptCrash(Throwable t, const(char)[] message = "") inout
        {

        }
    };

    class CustomException : Exception
    {
        this()
        {
            super("Exception!");
        }

        override string toString() const
        {
            return msg;
        }
    };

    immutable st = SysTime(DateTime(2023, 1, 1, 11, 30, 10), UTC());

    immutable crashName = crHandler.createCrashName(st);
    assert(crashName == "crash_local-2023-01-01T11_30_10Z_utc-2023-01-01T11_30_10Z", crashName);

    immutable crashInfo = crHandler.createCrashInfo(new CustomException, "Message.");
    assert(crashInfo.length > 0);
    assert(crashInfo == "Message. Exception!", crashInfo);

    immutable crashNullMessage = crHandler.createCrashInfo(new CustomException, null);
    assert(crashNullMessage == "Exception!", crashNullMessage);

    immutable crashNullEx = crHandler.createCrashInfo(null, "Message.");
    assert(crashNullEx == "Message. Throwable is null.", crashNullEx);

    immutable crashNullNull = crHandler.createCrashInfo(null, null);
    assert(crashNullNull == "Throwable is null.", crashNullNull);
}
