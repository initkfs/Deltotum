module app.dm.kit.inputs.cursors.system_cursor;

import app.dm.kit.inputs.cursors.cursor: Cursor;
import app.dm.com.inputs.com_cursor : ComCursor;

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
