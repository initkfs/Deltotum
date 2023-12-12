module dm.com.graphics.com_screen;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;

enum ScreenOrientation
{
    none,
    landscape,
    landscapeFlipped,
    portrait,
    portraitFlipped
}

struct ScreenMode
{
    int width;
    int height;
    int rateHz;
}

struct ScreenDpi
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
    ComResult getCount(out size_t count) @nogc nothrow;
    ComResult getBounds(int index, out int x, out int y,
        out int width, out int height) @nogc nothrow;
    ComResult getUsableBounds(int index, out int x, out int y, out int width, out int height) @nogc nothrow;
    ComResult getName(int index, ref const(char)* name) @nogc nothrow;
    ComResult getMode(int index, out ScreenMode mode) @nogc nothrow;
    ComResult getDPI(int index, out ScreenDpi screenDPI) @nogc nothrow;
    ComResult getOrientation(int index, out ScreenOrientation result);

}
