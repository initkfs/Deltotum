module deltotum.platform.sdl.sdl_clipboard;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.sdl.base.sdl_object : SdlObject;
import deltotum.platform.results.platform_result : PlatformResult;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlClipboard : SdlObject
{
    PlatformResult getText(out string newText)
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
            return PlatformResult.error(error);
        }

        import std.string : fromStringz;
        newText = text.fromStringz.idup;
        return PlatformResult.success;
    }

    PlatformResult hasText(out bool isHasText)
    {
        const SDL_bool result = SDL_HasClipboardText();
        isHasText = typeConverter.toBool(result);
        return PlatformResult.success;
    }

    PlatformResult setText(const char* text)
    {
        const zeroOrErrorCode = SDL_SetClipboardText(text);
        return PlatformResult(zeroOrErrorCode);
    }
}
