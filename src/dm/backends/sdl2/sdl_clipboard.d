module dm.backends.sdl2.sdl_clipboard;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.inputs.com_clipboard: ComClipboard;
import dm.backends.sdl2.base.sdl_object : SdlObject;
import dm.com.platforms.results.com_result : ComResult;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlClipboard : SdlObject, ComClipboard
{
    ComResult getText(out string newText)
    {
        const(char*) text = SDL_GetClipboardText();
        scope (exit)
        {
            SDL_free(cast(void*) text);
        }
        if (!text)
        {
            string error = "Error getting text from clipboard.";
            if (const err = getError)
            {
                error ~= err;
            }
            return ComResult.error(error);
        }

        import std.string : fromStringz;

        newText = text.fromStringz.idup;
        return ComResult.success;
    }

    ComResult hasText(out bool isHasText)
    {
        const SDL_bool result = SDL_HasClipboardText();
        isHasText = typeConverter.toBool(result);
        return ComResult.success;
    }

    ComResult setText(const char* text)
    {
        const zeroOrErrorCode = SDL_SetClipboardText(text);
        return ComResult(zeroOrErrorCode);
    }

    bool isDisposed() @nogc nothrow pure @safe
    {
        return false;
    }

    bool dispose() @nogc nothrow
    {
        return false;
    }
}
