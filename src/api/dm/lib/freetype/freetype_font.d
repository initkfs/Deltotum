module api.dm.lib.freetype.freetype_font;

/**
 * Authors: initkfs
 */
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_font : ComFont, ComFontRenderMode;
import api.dm.com.graphics.com_surface : ComSurface;

import api.dm.lib.freetype.native;
import api.dm.lib.freetype.native.binddynamic : FreeTypeLib;

import std.string : toStringz, fromStringz;

import Math = api.math;

class FreeTypeFont : ComFont
{
    protected
    {
        string _path;
        uint _size;
        uint _maxHeight;

        FT_Face _face;
        FreeTypeLib _lib;
    }

    this(FreeTypeLib lib)
    {
        if (!lib)
        {
            throw new Exception("Free type library must not be null");
        }
        this._lib = lib;
    }

    ComResult create(string path, uint size) nothrow
    {
        this._path = path;
        if (_path.length == 0)
        {
            return ComResult.error("Font path must not be empty");
        }

        this._size = size;
        if (_size == 0)
        {
            return ComResult.error("Font size must not be 0");
        }

        if (const err = FT2_FT_New_Face(_lib.library, path.toStringz, 0, &_face))
        {
            return ComResult.error("Font face error");
        }

        if (const err = FT2_FT_Select_Charmap(_face, FT_ENCODING_UNICODE))
        {
            return ComResult.error("Error unicode tag selection");
        }

        if (const err = FT2_FT_Set_Pixel_Sizes(_face, 0, _size))
        {
            return ComResult.error("Font size error");
        }

        return ComResult.success;
    }

    bool hasCode(ulong code)
    {
        assert(_face);
        int res = FT2_FT_Get_Char_Index(_face, code);
        if (res != 0)
        {
            return true;
        }

        return false;
    }

    ComResult render(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr = 0, ubyte fg = 0, ubyte fb = 0, ubyte fa = 255,
        ubyte br = 0, ubyte bg = 0, ubyte bb = 0, ubyte ba = 255,
        float alphaGamma, ComFontRenderMode mode) nothrow
    {
        final switch (mode) with (ComFontRenderMode)
        {
            case normal:
                return renderMode(targetSurface, text, ComFontRenderMode.normal, fr, fg, fb, fa, alphaGamma);
            case light:
                return renderMode(targetSurface, text, ComFontRenderMode.light, fr, fg, fb, fa, alphaGamma);
            case lcd:
                return renderLCD(targetSurface, text, fr, fg, fb, fa, br, bg, bb, ba, alphaGamma);
            case sdf:
                throw new Error("Not supported render mode");
        }
    }

    ComResult applySurface(
        ComSurface targetSurface,
        const(dchar[]) text,
        out int baselineY,
        ubyte br = 0, ubyte bg = 0, ubyte bb = 0, ubyte ba = 0
    ) nothrow
    {

        int minW = 1;
        int minH = 1;

        int ascent = cast(int)(_face.size.metrics.ascender >> 6);
        int descent = cast(int)(_face.size.metrics.descender >> 6);

        int surfaceHeight = ascent - descent;

        int surfaceWidth = 0;
        foreach (dchar p; text)
        {
            int codep = cast(int) p;

            if (FT2_FT_Load_Char(_face, codep, FT_LOAD_NO_BITMAP))
            {
                continue;
            }

            surfaceWidth += (_face.glyph.advance.x >> 6);
        }

        if (surfaceWidth == 0)
        {
            surfaceWidth = minW;
        }

        if (surfaceHeight == 0)
        {
            surfaceHeight = minH;
        }

        if (const err = targetSurface.createRGBA32(surfaceWidth, surfaceHeight))
        {
            return err;
        }

        if (const err = targetSurface.fill(br, bg, bb, ba))
        {
            return err;
        }

        import api.dm.com.graphics.com_blend_mode : ComBlendMode;

        if (const err = targetSurface.setBlendMode(ComBlendMode.blend))
        {
            return err;
        }

        baselineY = ascent;

        if (surfaceHeight > _maxHeight)
        {
            _maxHeight = surfaceHeight;
        }

        return ComResult.success;
    }

    ComResult renderMode(
        ComSurface targetSurface,
        const(dchar[]) text,
        ComFontRenderMode mode,
        ubyte fr, ubyte fg, ubyte fb, ubyte fa,
        float alphaGamma) nothrow
    {

        int baselineY;
        if (const err = applySurface(targetSurface, text, baselineY))
        {
            return err;
        }

        uint flags = FT_LOAD_RENDER;
        if (mode == ComFontRenderMode.light)
        {
            mode |= FT_LOAD_TARGET_LIGHT;
        }

        int penX = 0;
        foreach (dchar p; text)
        {
            auto codep = cast(int) p;
            //FT_LOAD_FORCE_AUTOHINT
            if (FT2_FT_Load_Char(_face, codep, flags))
            {
                continue;
            }

            FT_GlyphSlot slot = _face.glyph;
            FT_Bitmap* bitmap = &slot.bitmap;

            int drawX = penX + slot.bitmap_left;
            int drawY = baselineY - slot.bitmap_top;

            //TODO FIXME, invisible fonts
            enum colorMin = 12;
            if (fr == 0 && fg == 0 && fb == 0)
            {
                fr = colorMin;
                fg = colorMin;
                fb = colorMin;
            }

            for (int row = 0; row < bitmap.rows; row++)
            {
                for (int col = 0; col < bitmap.width; col++)
                {
                    int x = drawX + col;
                    int y = drawY + row;

                    if (x < 0 || x >= targetSurface.getWidth || y < 0 || y >= targetSurface
                        .getHeight)
                    {
                        continue;
                    }

                    int baseIdx = row * bitmap.pitch + col;
                    ubyte brightness = bitmap.buffer[baseIdx];

                    if (brightness == 0)
                    {
                        continue;
                    }

                    //float fontAlpha = brightness / 255.0f;
                    ubyte outR = fr;
                    ubyte outG = fg;
                    ubyte outB = fb;

                    ubyte outA;
                    if (alphaGamma == 1)
                    {
                        outA = brightness;
                    }
                    else
                    {
                        float linearAlpha = brightness / 255.0;
                        linearAlpha = Math.pow(linearAlpha, alphaGamma);
                        outA = cast(ubyte)(fa * linearAlpha);
                    }

                    if (!targetSurface.setPixel(x, y, outR, outG, outB, outA))
                    {
                        return ComResult.error(
                            "Error setting font pixel: " ~ targetSurface.lastError);
                    }
                }
            }

            penX += (slot.advance.x >> 6);
        }

        return ComResult.success;
    }

    ComResult renderLCD(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr, ubyte fg, ubyte fb, ubyte fa,
        ubyte br, ubyte bg, ubyte bb, ubyte ba,
        float alphaGamma) nothrow
    {

        int baselineY;
        if (const err = applySurface(targetSurface, text, baselineY, br, bg, bb, ba))
        {
            return err;
        }

        int penX = 0;

        foreach (dchar p; text)
        {
            auto codep = cast(int) p;
            //FT_LOAD_FORCE_AUTOHINT
            if (FT2_FT_Load_Char(_face, codep, FT_LOAD_RENDER | FT_LOAD_TARGET_LCD))
            {
                continue;
            }

            FT_GlyphSlot slot = _face.glyph;

            FT_Bitmap* bitmap = &slot.bitmap;

            int drawX = penX + slot.bitmap_left;
            int drawY = baselineY - slot.bitmap_top;

            int logicalWidth = bitmap.width / 3;

            enum colorMin = 5;
            if (fr == 0 && fg == 0 && fb == 0)
            {
                fr = colorMin;
                fg = colorMin;
                fb = colorMin;
            }

            for (int row = 0; row < bitmap.rows; row++)
            {
                for (int col = 0; col < logicalWidth; col++)
                {
                    int x = drawX + col;
                    int y = drawY + row;

                    if (x < 0 || x >= targetSurface.getWidth || y < 0 || y >= targetSurface
                        .getHeight)
                    {
                        continue;
                    }

                    //For LCD only
                    int base_idx = row * bitmap.pitch + col * 3;
                    ubyte r = bitmap.buffer[base_idx];
                    ubyte g = bitmap.buffer[base_idx + 1];
                    ubyte b = bitmap.buffer[base_idx + 2];

                    ubyte alpha = cast(ubyte)((r + g + b) / 3);
                    // //ubyte alpha = cast(ubyte)(Math.max(r, Math.max(g, b)));

                    if (alpha == 0)
                    {
                        continue;
                    }

                    if (alpha == ubyte.max)
                    {
                        if (const err = targetSurface.setPixel(x, y, fr, fg, fb, fa))
                        {

                        }
                        continue;
                    }

                    ubyte bgR = br;
                    ubyte bgG = bg;
                    ubyte bgB = bb;
                    ubyte bgA = ba;

                    float a = alpha / 255.0f;
                    if (alphaGamma != 1)
                    {
                        a = Math.pow(a, alphaGamma);
                    }

                    float invA = 1.0f - a;
                    ubyte outR = cast(ubyte)(fr * a + bgR * invA);
                    ubyte outG = cast(ubyte)(fg * a + bgG * invA);
                    ubyte outB = cast(ubyte)(fb * a + bgB * invA);
                    //ubyte outA = cast(ubyte) Math.max(alpha, bgA);

                    float outa = a + bgA / (cast(float) ubyte.max) * (1 - a);
                    ubyte outA = cast(ubyte)(outa * ubyte.max);

                    if (!targetSurface.setPixel(x, y, outR, outG, outB, outA))
                    {
                        return ComResult.error(
                            "Error setting font pixel: " ~ targetSurface.lastError);
                    }
                }
            }

            penX += (slot.advance.x >> 6);
        }

        return ComResult.success;
    }

    float sRGBToLinear(float x) nothrow
    {
        return x <= 0.04045 ? x / 12.92 : Math.pow((x + 0.055) / 1.055, 2.4);
    }

    float linearTosRGB(float x) nothrow
    {
        return x <= 0.0031308 ? x * 12.92 : 1.055 * Math.pow(x, 1 / 2.4) - 0.055;
    }

    string getFontPath() nothrow => _path;
    uint getFontSize() nothrow => _size;
    uint getMaxHeight() nothrow => _maxHeight;

    bool dispose() nothrow
    {
        if (!_face)
        {
            return false;
        }

        if (!FT2_FT_Done_Face)
        {
            return false;
        }

        FT2_FT_Done_Face(_face);
        _face = null;
        return true;
    }

    bool isDisposed() pure nothrow @safe => _face is null;
}
