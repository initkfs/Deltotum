module app.dm.com.inputs.com_clipboard;

import app.dm.com.platforms.results.com_result : ComResult;
import app.dm.com.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComClipboard : Destroyable
{
nothrow:

    ComResult hasText(out bool isHasText);
    ComResult getText(out string newText);
    ComResult setText(const(char)[] text);
}
