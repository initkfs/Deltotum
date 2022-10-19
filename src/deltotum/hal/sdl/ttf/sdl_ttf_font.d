module deltotum.hal.sdl.ttf.sdl_ttf_font;

import deltotum.hal.result.hal_result : HalResult;
import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.ttf.base.sdl_ttf_object : SdlTTFObject;
import deltotum.hal.sdl.sdl_surface: SdlSurface;

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

    HalResult render(SdlSurface targetFontSurface, const char* text, ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 1)
    {
        SDL_Color color = {r, g, b, a};
        auto fontSurfacePtr = TTF_RenderUTF8_Blended(ptr, text, color);
        if (!fontSurfacePtr)
        {
            string errMsg = "Unable to render text";
            if (const sdlErr = getError)
            {
                errMsg ~= ". " ~ errMsg;
            }
            return HalResult(-1, errMsg);
        }

        targetFontSurface.updateObject(fontSurfacePtr);

        return HalResult();
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
