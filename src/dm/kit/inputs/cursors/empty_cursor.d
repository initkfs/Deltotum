module dm.kit.inputs.cursors.empty_cursor;

//TODO move cursor and mouse
import dm.com.inputs.cursors.com_cursor: ComCursor;
import dm.kit.inputs.cursors.system_cursor: SystemCursor;

/**
 * Authors: initkfs
 */
class EmptyCursor : SystemCursor
{
    this(ComCursor defaultCursor)
    {
        super(defaultCursor);
    }
    
}
