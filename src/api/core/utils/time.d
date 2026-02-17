module api.core.utils.time;

/**
 * Authors: initkfs
 */
import core.stdc.time : time_t, time, gmtime, tm, strftime;
import std.string : toStringz;

tm* utcTime()
{
    time_t now = time(null);
    tm* utc = gmtime(&now);
    return utc;
}

size_t utcTimeBuff(char[] buffer, string format = "%Y-%m-%d %H:%M:%S")
{
    return strftime(buffer.ptr, buffer.length, format.toStringz, utcTime);
}
