module api.dm.kit.assets.fonts.caches.font_cache;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.com.graphic.com_font: ComFont;
import api.dm.kit.assets.fonts.font_size : FontSize;

/**
 * Authors: initkfs
 */
class FontCache
{
    const string name;

    protected
    {
        ComFont[size_t] _fontCache;
        BitmapFont[RGBA][size_t] _bitmapCache;
    }

    this(string name) pure @safe
    {
        if (name.length == 0)
        {
            throw new Exception("Font name must not be empty");
        }
        this.name = name;
    }

    inout(ComFont) defaultFont() inout
    {
        return font(FontSize.medium);
    }

    inout(ComFont*) hasFont(size_t size) inout
    {
        return size in _fontCache;
    }

    inout(ComFont) font(size_t size) inout
    {
        if (auto fontPtr = hasFont(size))
        {
            return *fontPtr;
        }
        //return nullable, but there are a lot of frequent checks
        import std.format : format;

        throw new Exception(format("Not found font '%s' with size '%s'", name, size));
    }

    void addFont(size_t size, ComFont font)
    {
        _fontCache[size] = font;
    }

    inout(BitmapFont*) hasBitmap(size_t size, RGBA color) inout
    {
        if (auto colorCachePtr = size in _bitmapCache)
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

    void bitmap(BitmapFont font, size_t size, RGBA color)
    {
        if (auto colorCachePtr = size in _bitmapCache)
        {
            (*colorCachePtr)[color] = font;
        }
        else
        {
            BitmapFont[RGBA] colorCache = [color: font];
            _bitmapCache[size] = colorCache;
        }
    }

    void dispose()
    {
        foreach (font; _fontCache)
        {
            if (!font.isDisposed)
            {
                font.dispose;
            }
        }
        _fontCache = null;

        foreach (size, colorCache; _bitmapCache)
        {
            foreach (ref color, bitmap; colorCache)
            {
                if (!bitmap.isDisposed)
                {
                    bitmap.dispose;
                }
            }
        }

        _bitmapCache = null;
    }

}
