module api.dm.kit.inputs.clipboards.clipboard;

import api.dm.com.inputs.com_clipboard: ComClipboard;

/**
 * Authors: initkfs
 */
class Clipboard
{
    private
    {
        ComClipboard clipboard;
    }

    this(ComClipboard c)
    {
        assert(c);
        this.clipboard = c;
    }

    string getText(){
        string result;
        const err = clipboard.getText(result);
        if(err){
            throw new Exception(err.toString);
        }
        return result;
    }

    bool setText(string text)
    {
        import std.string : toStringz;

        const err = clipboard.setText(text);
        if (err)
        {
            //logging?
            return false;
        }
        return true;
    }

    bool hasText()
    {
        bool isHasText;
        const err = clipboard.hasText(isHasText);
        if (err)
        {
            throw new Exception(err.toString);
        }
        return isHasText;
    }

    void dispose(){
        clipboard.dispose;
    }
}
