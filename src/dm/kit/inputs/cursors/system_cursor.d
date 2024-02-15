module dm.kit.inputs.cursors.system_cursor;

import dm.kit.inputs.cursors.cursor: Cursor;
import dm.com.inputs.cursors.com_cursor : ComCursor;

/**
 * Authors: initkfs
 */
class SystemCursor : Cursor
{
    this(ComCursor defaultCursor)
    {
        assert(defaultCursor);
        this.defaultCursor = defaultCursor;
    }
}
