module api.core.utils.time;

/**
 * Authors: initkfs
 */
import core.stdc.time : time_t, time, gmtime, localtime, tm, strftime;
import std.string : toStringz;

enum defaultTimeFormat = "%Y-%m-%d %H:%M:%S";

time_t nowTime() => time(null);

tm* utcTime(time_t time) => gmtimeut(&time);
tm* utcTime() => utcTime(nowTime);

tm* localTime(time_t time) => localtime(&time);
tm* localTime() => localTime(nowTime);

size_t formatTime(char[] buffer, tm* time, string format = defaultTimeFormat)
{
    return strftime(buffer.ptr, buffer.length, format.toStringz, time);
}

size_t utcTimeBuff(char[] buffer, string format = defaultTimeFormat)
{
    return formatTime(buffer, utcTime, format);
}
