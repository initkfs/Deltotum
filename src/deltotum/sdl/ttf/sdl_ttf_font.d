module deltotum.sdl.ttf.sdl_ttf_font;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.platform.results.platform_result : PlatformResult;
import deltotum.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sdl.ttf.base.sdl_ttf_object : SdlTTFObject;
import deltotum.sdl.sdl_surface: SdlSurface;

import bindbc.sdl;

import std.string : toStringz;

/**
 * Authors: initkfs
 */
class SdlTTFFont : SdlObjectWrapper!TTF_Font
{
    private
    {
        string path;
        int fontSize;
    }

    this(string fontFilePath, int fontSize = 12)
    {
        this.path = fontFilePath;
        this.fontSize = fontSize;
        ptr = TTF_OpenFont(this.path.toStringz, fontSize);
        if (!ptr)
        {
            //TODO error from sdl?
            string error = "Unable to load ttf font.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    PlatformResult render(SdlSurface targetFontSurface, const char* text, ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 1)
    {
        SDL_Color color = {r, g, b, a};
        //TODO calculate background color
        auto fontSurfacePtr = TTF_RenderUTF8_Blended(ptr, text, color);
        if (!fontSurfacePtr)
        {
            string errMsg = "Unable to render text";
            if (const sdlErr = getError)
            {
                errMsg ~= ". " ~ errMsg;
            }
            return PlatformResult(-1, errMsg);
        }

        targetFontSurface.updateObject(fontSurfacePtr);

        return PlatformResult();
    }

    override bool destroyPtr()
    {
        if (ptr)
        {
            TTF_CloseFont(ptr);
            return true;
        }
        return false;
    }

}
