module api.dm.com.graphics.com_screen;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_window : ComWindow;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.com_error_manageable : ComErrorManageable;

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
    float rateHz;
    float density;
}

struct ComScreenDpi
{
    float diagonalDPI = 0;
    float horizontalDPI = 0;
    float verticalDPI = 0;
}

/**
 * Authors: initkfs
 */
interface ComScreen : ComDestroyable, ComErrorManageable
{

nothrow:

    void onScreens(scope bool delegate(ComScreenId) nothrow onScreenIdIsContinue);

    ComResult getScreenForWindow(ComWindow window, out ComScreenId id);

    bool getBounds(ComScreenId id, out int x, out int y, out int width, out int height);
    bool getUsableBounds(ComScreenId id, out int x, out int y, out int width, out int height);
    bool getMode(ComScreenId id, out ComScreenMode mode);
    bool getOrientation(ComScreenId id, out ComScreenOrientation result);

    string getNameNew(ComScreenId id);
    string getDriverNameNew();
}
