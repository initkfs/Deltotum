module api.dm.com.inputs.com_cursor;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;

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
interface ComCursor : ComDestroyable
{
nothrow:

    ComResult createFromType(ComPlatformCursorType type);
    ComResult createDefault();
    ComResult show();
    ComResult hide();
    ComResult set();
    ComResult redraw();
    ComResult getPos(out float x, out float y);

}
