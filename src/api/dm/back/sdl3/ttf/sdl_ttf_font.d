module api.dm.back.sdl3.ttf.sdl_ttf_font;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.graphics.com_font : ComFont, ComFontHinting;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.ttf.base.sdl_ttf_object : SdlTTFObject;
import api.dm.com.graphics.com_surface : ComSurface;

import std.conv : to;

import api.dm.back.sdl3.externs.csdl3;

import std.string : toStringz;

/**
 * Authors: initkfs
 */
class SdlTTFFont : SdlObjectWrapper!TTF_Font, ComFont
{
    private
    {
        string _fontPath;
        double _fontSize;
        double _maxHeight = 1;
    }

    ComResult load(string fontFilePath, double fontSize = 12) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        if (fontFilePath.length == 0)
        {
            return ComResult.error("Font file path must not be empty");
        }

        if (fontSize == 0)
        {
            return ComResult.error("Font file size must be positive number");
        }

        this._fontPath = fontFilePath;
        this._fontSize = fontSize;

        ptr = TTF_OpenFont(_fontPath.toStringz, cast(float) _fontSize);
        if (!ptr)
        {
            return getErrorRes("Unable to load ttf font from " ~ fontFilePath);
        }

        _maxHeight = TTF_GetFontHeight(ptr);

        return ComResult.success;
    }

    ComResult renderFont(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr = 255, ubyte fg = 255, ubyte fb = 255, ubyte fa = 255,
        ubyte br = 255, ubyte bg = 255, ubyte bb = 255, ubyte ba = 255) nothrow
    {
        assert(targetSurface);

        SDL_Color color = {fr, fg, fb, fa};
        //TODO TTF_RenderText_Shaded
        SDL_Color backgroundColor = {br, bg, bb, ba};
        //TODO calculate background color
        import std.utf : toUTFz;

        const(char)* textPtr;
        try
        {
            textPtr = toUTFz!(const(char)*)(text);
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }

        assert(textPtr);

        SDL_Surface* fontSurfacePtr = TTF_RenderText_Blended(ptr, textPtr, 0, color);
        if (!fontSurfacePtr)
        {
            return getErrorRes("Unable to render text");
        }

        //TODO unsafe
        if (const err = targetSurface.createFromPtr(cast(void*) fontSurfacePtr))
        {
            return err;
        }

        return ComResult.success;
    }

    ComResult getFontPath(out string path) nothrow
    {
        assert(ptr, "Font not loaded");

        path = this._fontPath;
        return ComResult.success;
    }

    ComResult getFontSize(out double size) nothrow
    {
        assert(ptr, "Font not loaded");
        size = _fontSize;
        return ComResult.success;
    }

    ComResult setHinting(ComFontHinting hinting)
    {
        TTF_HintingFlags sdlHinting;
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

    ComResult getMaxHeight(out double size)
    {
        size = _maxHeight;
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
