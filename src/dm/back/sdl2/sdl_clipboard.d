module dm.back.sdl2.sdl_clipboard;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.inputs.com_clipboard : ComClipboard;
import dm.back.sdl2.base.sdl_object : SdlObject;
import dm.com.platforms.results.com_result : ComResult;

import bindbc.sdl;

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
        const SDL_bool result = SDL_HasClipboardText();
        isHasText = typeConverter.toBool(result);
        return ComResult.success;
    }

    ComResult setText(const(char)[] text) nothrow
    {
        import std.string : toStringz;

        const zeroOrErrorCode = SDL_SetClipboardText(text.toStringz);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    bool isDisposed() nothrow pure @safe
    {
        return false;
    }

    bool dispose() nothrow
    {
        return false;
    }
}
