module api.core.apps.crashes.syslog_crash_handler;

import api.core.apps.crashes.time_crash_handler : TimeCrashHandler;

import core.sys.posix.syslog;
import core.sys.posix.signal;
import core.sys.posix.unistd : _exit;
import std.string : toStringz;

/**
 * Authors: initkfs
 */
class SyslogCrashHandler : TimeCrashHandler
{
    protected
    {
        string appName;
        bool isOpen;
    }

    this(string appName)
    {
        this.appName = appName;
    }

    override void acceptCrash(Throwable t, const(char)[] message = "")
    {
        try
        {
            if (!isOpen)
            {
                openlog(appName.toStringz, LOG_PID, LOG_USER);
                isOpen = true;
            }

            import std.format : format;

            const result = format("Message: '%s', error: %s\n", message, t);
            syslog(LOG_ERR, result.toStringz);
        }
        catch (Exception e)
        {
            import std.stdio : writeln, stderr;

            stderr.writeln(e.toString);
        }
    }
}
