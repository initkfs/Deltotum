module dm.com.platforms.com_system;

import dm.com.platforms.results.com_result : ComResult;

/**
 * Authors: initkfs
 */
interface ComSystem
{
    ComResult openURL(string link) nothrow;
}
