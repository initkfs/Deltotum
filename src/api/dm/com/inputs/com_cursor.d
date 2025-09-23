module api.dm.com.inputs.com_cursor;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_window: ComWindow;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.com_error_manageable: ComErrorManageable;

enum ComPlatformCursorType
{
    none,
    arrow,
    crossHair,
    ibeam,
    no,
    sizeNorthWestSouthEast,
    sizeNorthEastSouthWest,
    sizeWestEast,
    sizeNorthSouth,
    sizeAll,
    hand,
    wait,
    waitArrow,
}

/**
 * Authors: initkfs
 */
interface ComCursor : ComDestroyable, ComErrorManageable
{
nothrow:

    ComResult createFromType(ComPlatformCursorType type);
    ComResult createDefault();
    ComResult getWindowHasFocus(ComWindow buffer);
    
    bool show();
    bool hide();
    bool set();
    bool isVisible();
    bool redraw();
    bool getPos(out float x, out float y);
}
