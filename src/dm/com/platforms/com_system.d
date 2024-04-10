module dm.com.platforms.com_system;

import dm.com.platforms.results.com_result : ComResult;

extern (C) nothrow alias RetNextIntervalCallback = uint function(uint interval, void* param);

/**
 * Authors: initkfs
 */
interface ComSystem
{
nothrow:
    ComResult openURL(string link) nothrow;
    ComResult addTimer(out int timerId, int intervalMs, RetNextIntervalCallback callback, void* param);
    ComResult removeTimer(int timerId);
}
