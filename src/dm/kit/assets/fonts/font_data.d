module dm.kit.assets.fonts.font_data;

import dm.core.units.services.loggable_unit : LoggableUnit;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import dm.kit.assets.fonts.font : Font;
import dm.kit.assets.fonts.font_size: FontSize;

/**
 * Authors: initkfs
 */
class FontData
{
    const string name;

    protected
    {
        Font[size_t] _map;
        BitmapFont[RGBA][size_t] _bitmap;
    }

    this(string name)
    {
        if (name.length == 0)
        {
            throw new Exception("Font name must not be empty");
        }
        this.name = name;
    }

    inout(Font*) hasFont(size_t size) inout
    {
        return size in _map;
    }

    inout(Font) fontBySize(size_t size) inout
    {
        if (auto fontPtr = hasFont(size))
        {
            return *fontPtr;
        }
        //return nullable, but there are a lot of frequent checks
        import std.format : format;

        throw new Exception(format("Not found font '%s' with size '%s'", name, size));
    }

    void fontBySize(size_t size, Font font)
    {
        _map[size] = font;
    }

    inout(BitmapFont*) hasBitmap(size_t size, RGBA color) inout
    {
        if (auto colorCachePtr = size in _bitmap)
        {
            if (auto fontPtr = color in *colorCachePtr)
            {
                return fontPtr;
            }
        }
        return null;
    }

    inout(BitmapFont) bitmap(size_t size, RGBA color) inout
    {
        if (auto fontPtr = hasBitmap(size, color))
        {
            return *fontPtr;
        }
        //return nullable, but there are a lot of frequent checks
        import std.format : format;

        throw new Exception(format("Not found bitmap for size '%s', color '%s', name '%s'", size, color, name));
    }

    void bitmap(size_t size, RGBA color, BitmapFont font)
    {
        if (auto colorCachePtr = size in _bitmap)
        {
            (*colorCachePtr)[color] = font;
        }
        else
        {
            BitmapFont[RGBA] colorCache = [color: font];
            _bitmap[size] = colorCache;
        }
    }

}
