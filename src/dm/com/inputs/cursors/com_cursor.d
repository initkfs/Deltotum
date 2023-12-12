module dm.com.inputs.cursors.com_cursor;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;

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
   ComResult fromDefaultCursor() @nogc nothrow;
   ComResult set() @nogc nothrow;
   ComResult redraw() @nogc nothrow;

}
