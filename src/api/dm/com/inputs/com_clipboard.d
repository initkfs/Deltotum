module api.dm.com.inputs.com_clipboard;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;

/**
 * Authors: initkfs
 */
interface ComClipboard : ComDestroyable
{
nothrow:

    ComResult hasText(out bool isHasText);
    ComResult getText(out string newText);
    ComResult setText(const(char)[] text);

    ComResult hasData(string dataType, out bool isHasData);
    ComResult getData(string dataType, scope void delegate(void* data, size_t dataLength) nothrow onData);

    ComResult getPrimarySelectionText(out string newText);
    ComResult setPrimarySelectionText(const(char)[] text);
    ComResult hasPrimarySelectionText(out bool isHasText);
}
