module api.dm.com.graphic.com_screen;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_window : ComWindow;
import api.dm.com.com_destroyable : ComDestroyable;

alias ComScreenId = int;

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
    ComScreenId id;
    int width;
    int height;
    double rateHz;
    double density;
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
interface ComScreen : ComDestroyable
{

nothrow:

    ComResult onScreens(scope bool delegate(ComScreenId) nothrow onScreenIdIsContinue);
    ComResult getBounds(ComScreenId id, out int x, out int y, out int width, out int height);
    ComResult getUsableBounds(ComScreenId id, out int x, out int y, out int width, out int height);
    ComResult getName(ComScreenId id, out string name);
    ComResult getVideoDriverName(out string name);
    ComResult getMode(ComScreenId id, out ComScreenMode mode);
    ComResult getScreenForWindow(ComWindow window, out ComScreenId id);
    ComResult getOrientation(ComScreenId id, out ComScreenOrientation result);

}
