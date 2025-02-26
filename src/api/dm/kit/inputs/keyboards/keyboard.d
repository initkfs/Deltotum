module api.dm.kit.inputs.keyboards.keyboard;

import api.dm.com.inputs.com_keyboard : ComKeyboard;

/**
 * Authors: initkfs
 */
class Keyboard
{
    protected
    {
        ComKeyboard comKeyBoard;
    }

    this(ComKeyboard kb)
    {
        assert(kb);
        this.comKeyBoard = kb;
    }
}
