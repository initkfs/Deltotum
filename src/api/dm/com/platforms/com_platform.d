module api.dm.com.platforms.com_platform;

import api.dm.com.com_result : ComResult;

extern (C) alias RetNextIntervalCallback = uint function(void* userdata, uint timerID, uint interval) nothrow ;

/**
 * Authors: initkfs
 */
interface ComPlatform
{
nothrow:
    ComResult openURL(string link) nothrow;
    ComResult add(out int timerId, uint intervalMs, RetNextIntervalCallback callback, void* param);
    ComResult remove(int timerId);
}
