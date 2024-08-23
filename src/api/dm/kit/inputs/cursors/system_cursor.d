module api.dm.kit.inputs.cursors.system_cursor;

import api.dm.kit.inputs.cursors.cursor: Cursor;
import api.dm.com.inputs.com_cursor : ComCursor;

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
