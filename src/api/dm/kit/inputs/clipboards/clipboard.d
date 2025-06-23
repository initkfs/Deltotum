module api.dm.kit.inputs.clipboards.clipboard;

import api.core.loggers.logging : Logging;
import api.dm.com.inputs.com_clipboard : ComClipboard;

/**
 * Authors: initkfs
 */
class Clipboard
{
    private
    {
        ComClipboard clipboard;
        Logging logging;
    }

    this(ComClipboard c, Logging logging)
    {
        assert(logging);
        this.logging = logging;

        assert(c);
        this.clipboard = c;
    }

    string getText()
    {
        string result;
        getText(result);
        return result;
    }

    bool getText(out string text)
    {
        string result;
        if (const err = clipboard.getText(result))
        {
            logging.logger.error(err.toString);
            return false;
        }
        text = result;
        return true;
    }

    bool setText(dstring text)
    {
        import std.conv : to;

        return setText(text.to!string);
    }

    bool setText(string text)
    {
        import std.string : toStringz;

        if (const err = clipboard.setText(text))
        {
            logging.logger.error(err.toString);
            return false;
        }

        return true;
    }

    bool hasText()
    {
        bool isHasText;
        if (const err = clipboard.hasText(isHasText))
        {
            logging.logger.error(err.toString);
            return false;
        }

        return isHasText;
    }

    void dispose()
    {
        if (clipboard)
        {
            clipboard.dispose;
        }
    }
}
