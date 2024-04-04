module dm.com.graphics.com_screen;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;

enum ComScreenOrientation
{
    none,
    landscape,
    landscapeFlipped,
    portrait,
    portraitFlipped
}

struct ComScreenMode
{
    int width;
    int height;
    int rateHz;
}

struct ComScreenDpi
{
    double diagonalDPI = 0;
    double horizontalDPI = 0;
    double verticalDPI = 0;
}

/**
 * Authors: initkfs
 */
interface ComScreen : Destroyable
{
nothrow:

    ComResult getCount(out size_t count);
    ComResult getBounds(int index, out int x, out int y,
        out int width, out int height);
    ComResult getUsableBounds(int index, out int x, out int y, out int width, out int height);
    ComResult getName(int index, ref const(char)* name);
    ComResult getMode(int index, out ComScreenMode mode);
    ComResult getDPI(int index, out ComScreenDpi screenDPI);
    ComResult getOrientation(int index, out ComScreenOrientation result);

}
