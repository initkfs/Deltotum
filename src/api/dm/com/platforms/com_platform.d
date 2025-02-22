module api.dm.com.platforms.com_platform;

import api.dm.com.platforms.results.com_result : ComResult;

extern (C) alias RetNextIntervalCallback = uint function(void* userdata, uint timerID, uint interval) nothrow @nogc;

/**
 * Authors: initkfs
 */
interface ComPlatform
{
nothrow:
    ComResult openURL(string link) nothrow;
    ComResult addTimer(out int timerId, uint intervalMs, RetNextIntervalCallback callback, void* param);
    ComResult removeTimer(int timerId);
}
