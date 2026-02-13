module api.dm.lib.freetype.freetype_font;

/**
 * Authors: initkfs
 */
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_font : ComFont;
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

    ComResult renderFont(
        ComSurface targetSurface,
        const(dchar[]) text,
        ubyte fr = 0, ubyte fg = 0, ubyte fb = 0, ubyte fa = 255,
        ubyte br = 255, ubyte bg = 255, ubyte bb = 255, ubyte ba = 255) nothrow
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

        int baselineY = ascent;
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

            if (FT2_FT_Render_Glyph(slot, FT_Render_Mode.FT_RENDER_MODE_LCD))
            {
                continue;
            }

            FT_Bitmap* bitmap = &slot.bitmap;

            int drawX = penX + slot.bitmap_left;
            int drawY = baselineY - slot.bitmap_top;

            int logicalWidth = bitmap.width / 3;

            for (int row = 0; row < bitmap.rows; row++)
            {
                for (int col = 0; col < logicalWidth; col++)
                {
                    //For LCD
                    int base_idx = row * bitmap.pitch + col * 3;
                    ubyte r = bitmap.buffer[base_idx];
                    ubyte g = bitmap.buffer[base_idx + 1];
                    ubyte b = bitmap.buffer[base_idx + 2];

                    ubyte alpha = cast(ubyte)((r + g + b) / 3);
                    //ubyte alpha = bitmap.buffer[row * bitmap.pitch + col];
                    if (alpha == 0)
                        continue;

                    int x = drawX + col;
                    int y = drawY + row;

                    if (x < 0 || x >= targetSurface.getWidth || y < 0 || y >= targetSurface.getHeight)
                        continue;

                    // const ubyte ALPHA_THRESHOLD = 100;

                    // if (alpha < ALPHA_THRESHOLD)
                    // {
                    //     continue;
                    // }

                    if (alpha == ubyte.max)
                    {
                        if (const err = targetSurface.setPixelRGBA(x, y, fr, fg, fb, fa))
                        {

                        }
                        continue;
                    }

                    uint* pixel;

                    if (const err = targetSurface.getPixel(x, y, pixel))
                    {
                        return err;
                    }

                    ubyte bgR, bgG, bgB, bgA;
                    if (const err = targetSurface.getPixelRGBA(pixel, bgR, bgG, bgB, bgA))
                    {
                        bgR = 0;
                        bgG = 0;
                        bgB = 0;
                        bgA = 0;
                    }

                    // //float gamma = 1;
                    float a = alpha / 255.0f;
                    // //float a = Math.pow(alpha / 255.0f, gamma);
                    float invA = 1.0f - a;

                    ubyte outR = cast(ubyte)(fr * a + bgR * invA);
                    ubyte outG = cast(ubyte)(fg * a + bgG * invA);
                    ubyte outB = cast(ubyte)(fb * a + bgB * invA);
                    ubyte outA = cast(ubyte) Math.max(alpha, bgA);

                    if (const err = targetSurface.setPixelRGBA(x, y, outR, outG, outB, outA))
                    {
                        return err;
                    }
                }
            }

            penX += (slot.advance.x >> 6);
        }

        if (surfaceHeight > _maxHeight)
        {
            _maxHeight = surfaceHeight;
        }

        return ComResult.success;
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

        FT2_FT_Done_Face(_face);
        return true;
    }

    bool isDisposed() pure nothrow @safe => _face is null;
}
