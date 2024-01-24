module dm.backends.sdl2.ttf.sdl_ttf_font;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.graphics.com_font : ComFont, ComFontHinting;
import dm.com.platforms.results.com_result : ComResult;
import dm.backends.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import dm.backends.sdl2.ttf.base.sdl_ttf_object : SdlTTFObject;
import dm.com.graphics.com_surface : ComSurface;

import bindbc.sdl;

import std.string : toStringz;

/**
 * Authors: initkfs
 */
class SdlTTFFont : SdlObjectWrapper!TTF_Font, ComFont
{
    private
    {
        string _fontPath;
        int _fontSize;
    }

    this(string fontFilePath, int fontSize = 12)
    {
        this._fontPath = fontFilePath;
        this._fontSize = fontSize;
        ptr = TTF_OpenFont(this._fontPath.toStringz, fontSize);
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

    ComResult render(
        ComSurface targetSurface,
        const char* text,
        ubyte fr = 255, ubyte fg = 255, ubyte fb = 255, ubyte fa = 1,
        ubyte br = 255, ubyte bg = 255, ubyte bb = 255, ubyte ba = 1)
    {
        SDL_Color color = {fr, fg, fb, fa};
        //TODO TTF_RenderText_Shaded
        SDL_Color backgroundColor = {br, bg, bb, ba};
        //TODO calculate background color
        SDL_Surface* fontSurfacePtr = TTF_RenderUTF8_Blended(ptr, text, color);
        if (!fontSurfacePtr)
        {
            string errMsg = "Unable to render text";
            if (const sdlErr = getError)
            {
                errMsg ~= ". " ~ errMsg;
            }
            return ComResult.error(errMsg);
        }

        //TODO unsafe
        if(const err = targetSurface.loadFromPtr(cast(void*) fontSurfacePtr)){
            return err;
        }

        return ComResult.success;
    }

    ComResult fontPath(out string path)
    {
        path = this._fontPath;
        return ComResult.success;
    }

    ComResult fontSize(out int size)
    {
        size = _fontSize;
        return ComResult.success;
    }

    ComResult setHinting(ComFontHinting hinting)
    {
        int sdlHinting;
        final switch (hinting) with (ComFontHinting)
        {
            case none:
                sdlHinting = TTF_HINTING_NONE;
                break;
            case normal:
                sdlHinting = TTF_HINTING_NORMAL;
                break;
            case light:
                sdlHinting = TTF_HINTING_LIGHT;
                break;
            case mono:
                sdlHinting = TTF_HINTING_MONO;
                break;
        }
        TTF_SetFontHinting(ptr, sdlHinting);
        return ComResult.success;
    }

    override bool disposePtr()
    {
        if (ptr)
        {
            TTF_CloseFont(ptr);
            return true;
        }
        return false;
    }

}
