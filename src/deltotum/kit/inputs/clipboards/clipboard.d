module deltotum.kit.inputs.clipboards.clipboard;

//TODO remove SDL api
import deltotum.sys.sdl.sdl_clipboard : SdlClipboard;
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Clipboard
{
    private
    {
        SdlClipboard clipboard;
    }

    this(SdlClipboard c)
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

        const err = clipboard.setText(text.toStringz);
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
}
