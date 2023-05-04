module deltotum.sys.sdl.sdl_clipboard;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.sys.sdl.base.sdl_object : SdlObject;
import deltotum.com.platforms.results.com_result : ComResult;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlClipboard : SdlObject
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
}
