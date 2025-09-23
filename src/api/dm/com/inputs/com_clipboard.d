module api.dm.com.inputs.com_clipboard;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;

/**
 * Authors: initkfs
 */
interface ComClipboard : ComDestroyable
{
nothrow:

    string getTextNew();
    bool hasText();
    
    ComResult setText(const(char)[] text);

    bool hasData(string dataType, out bool isHasData);
    ComResult getData(string dataType, scope void delegate(void* data, size_t dataLength) nothrow onData);
    ComResult clearData();

    ComResult getPrimarySelectionTextNew(out string newText);
    ComResult setPrimarySelectionText(const(char)[] text);
    bool hasPrimarySelectionText(out bool isHasText);
}
