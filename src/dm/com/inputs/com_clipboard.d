module dm.com.inputs.com_clipboard;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;

/**
 * Authors: initkfs
 */
interface ComClipboard : Destroyable
{
    ComResult getText(out string newText);
    ComResult hasText(out bool isHasText);
    ComResult setText(const char* text);
}
