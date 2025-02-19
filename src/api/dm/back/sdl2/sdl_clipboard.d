module api.dm.back.sdl2.sdl_clipboard;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.inputs.com_clipboard : ComClipboard;
import api.dm.back.sdl2.base.sdl_object : SdlObject;
import api.dm.com.platforms.results.com_result : ComResult;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlClipboard : SdlObject, ComClipboard
{
    ComResult getText(out string newText) nothrow
    {
        const(char*) text = SDL_GetClipboardText();
        if (!text)
        {
            return getErrorRes("Error getting text from clipboard.");
        }

        scope (exit)
        {
            SDL_free(cast(void*) text);
        }

        import std.string : fromStringz;

        newText = text.fromStringz.idup;
        return ComResult.success;
    }

    ComResult hasText(out bool isHasText) nothrow
    {
        if (SDL_HasClipboardText())
        {
            isHasText = true;
        }

        return ComResult.success;
    }

    ComResult setText(const(char)[] text) nothrow
    {
        import std.string : toStringz;

        if (!SDL_SetClipboardText(text.toStringz))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    // ComResult getPrimarySelection(out string text) nothrow
    // {
    //     auto textPtr = SDL_GetPrimarySelectionText();
    //     if (!textPtr)
    //     {
    //         text = null;
    //     }
    //     import std.string : fromStringz;

    //     text = textPtr.fromStringz.idup;
    //     SDL_Free(textPtr);
    //     if (text.length == 0)
    //     {
    //         return ComResult.error(getError);
    //     }
    //     return ComResult.success;
    // }

    bool isDisposed() nothrow pure @safe
    {
        return false;
    }

    bool dispose() nothrow
    {
        return false;
    }
}
