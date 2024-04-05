module dm.com.inputs.com_cursor;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.destroyable : Destroyable;

enum ComSystemCursorType
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
interface ComCursor : Destroyable
{
nothrow:

    ComResult createFromType(ComSystemCursorType type);
    ComResult createDefault();
    ComResult show();
    ComResult hide();
    ComResult set();
    ComResult redraw();
    ComResult getPos(out int x, out int y);

}
