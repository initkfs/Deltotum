module api.dm.kit.assets.asset;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.core.loggers.logging : Logging;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

import api.dm.com.graphics.com_font : ComFont;

import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.assets.paths.path_resource : PathResource;
import api.dm.kit.assets.fonts.caches.font_cache : FontCache;
import api.dm.kit.assets.fonts.font_size : FontSize;

/**
 * Authors: initkfs
 */
class Asset : PathResource
{
    ComFont delegate() comFontProvider;

    enum defaultFontName = "DMDefaultFont";

    RGBA defaultFontColor;

    protected
    {
        FontCache[string] fontCaches;
    }

    string defaultImagesResourceDir = "images";
    string defaultFontResourceDir = "fonts";

    this(Logging logging, string assetsDir, ComFont delegate() comFontProvider) pure @safe
    {
        super(logging, assetsDir);

        if(!comFontProvider){
            throw new Exception("Font provider must not be null");
        }
        this.comFontProvider = comFontProvider;

        this.fontCaches[defaultFontName] = new FontCache(defaultFontName);
    }

    string imagePath(string imageFile) const
    {
        import std.path : isAbsolute;

        if (imageFile.isAbsolute)
        {
            return imageFile;
        }

        auto mustBeImagePath = fileResource(defaultImagesResourceDir, imageFile);
        if (mustBeImagePath.length == 0)
        {
            throw new Exception("Not found image in resources: " ~ imageFile);
        }

        return mustBeImagePath;
    }

    string fontPath(string fontFile) const
    {
        import std.path : isAbsolute;

        if (fontFile.isAbsolute)
        {
            return fontFile;
        }

        auto mustBeFontPath = fileResource(defaultFontResourceDir, fontFile);
        if (mustBeFontPath.length == 0)
        {
            import std.format : format;

            throw new Exception(format("Not found font file %s in resources dir %s", fontFile, defaultFontResourceDir));
        }
        return mustBeFontPath;
    }

    ComFont newFont(string fontFilePath, uint size)
    {
        const path = fontPath(fontFilePath);
        auto comFont = comFontProvider();
        if (const err = comFont.create(path, size))
        {
            throw new Exception(err.toString);
        }
        return comFont;
    }

    bool hasFont(uint size = FontSize.medium, string name = defaultFontName)
    {
        if (auto fontCachePtr = name in fontCaches)
        {
            return (*fontCachePtr).hasFont(size) !is null;
        }

        return false;
    }

    bool hasLargeFont(string name = defaultFontName) => hasFont(FontSize.large, name);
    bool hasSmallFont(string name = defaultFontName) => hasFont(FontSize.small, name);

    void addFont(ComFont font, uint size = FontSize.medium, string name = defaultFontName)
    {
        fontCaches[name].addFont(size, font);
    }

    void addFontSmall(ComFont font, string name = defaultFontName)
    {
        addFont(font, FontSize.small, name);
    }

    void addFontLarge(ComFont font, string name = defaultFontName)
    {
        addFont(font, FontSize.large, name);
    }

    ComFont font(uint size = FontSize.medium, string name = defaultFontName)
    {
        auto cachedFont = fontCaches[name].font(size);
        assert(cachedFont);
        return cachedFont;
    }

    ComFont fontSmall(string name = defaultFontName)
    {
        return font(FontSize.small, name);
    }

    ComFont fontLarge(string name = defaultFontName)
    {
        return font(FontSize.large, name);
    }

    void addFontColorBitmap(BitmapFont fontTexture, RGBA color, uint size = FontSize.medium, string name = defaultFontName)
    {
        //TODO error not exists
        fontCaches[name].bitmap(fontTexture, size, color);
    }

    void addFontColorBitmapLarge(BitmapFont fontTexture, RGBA color)
    {
        addFontColorBitmap(fontTexture, color, FontSize.large);
    }

    void addFontColorBitmapSmall(BitmapFont fontTexture, RGBA color)
    {
        addFontColorBitmap(fontTexture, color, FontSize.small);
    }

    void setFontBitmap(BitmapFont fontTexture)
    {
        addFontColorBitmap(fontTexture, defaultFontColor);
    }

    void setFontBitmapLarge(BitmapFont fontTexture)
    {
        addFontColorBitmap(fontTexture, defaultFontColor, FontSize.large);
    }

    void setFontBitmapSmall(BitmapFont fontTexture)
    {
        addFontColorBitmap(fontTexture, defaultFontColor, FontSize.small);
    }

    inout(BitmapFont*) hasColorBitmapUnsafe(RGBA color, uint size = FontSize.medium, string name = defaultFontName) inout
    {
        inout(FontCache)* ptr = name in fontCaches;
        if (!ptr)
        {
            return null;
        }
        return (*ptr).hasBitmap(size, color);
    }

    bool hasColorBitmap(RGBA color, uint size = FontSize.medium, string name = defaultFontName)
    {
        return hasColorBitmapUnsafe(color, size, name) !is null;
    }

    BitmapFont fontColorBitmap(RGBA color, uint size = FontSize.medium, string name = defaultFontName)
    {
        auto fontCache = fontCaches[name];
        auto bitmapPtr = fontCache.hasBitmap(size, color);
        if (!bitmapPtr)
        {
            logger.warningf("Not found font bitmap in cache for size %s and color %s", size, color);
            auto defaultCache = fontCaches[defaultFontName];
            auto defaultBitmapPtr = defaultCache.hasBitmap(FontSize.medium, defaultFontColor);
            if (!defaultBitmapPtr)
            {
                import std.format : format;

                throw new Exception(format(
                        "Failed to get default bitmap to replace not-existing bitmap with color %s, size %s, name %s", color, size, name));
            }
            return *defaultBitmapPtr;
        }
        return *bitmapPtr;
    }

    BitmapFont fontBitmap(uint size = FontSize.medium, string name = defaultFontName)
    {
        return fontColorBitmap(defaultFontColor, size, name);
    }

    BitmapFont fontBitmapLarge()
    {
        return fontColorBitmap(defaultFontColor, FontSize.large);
    }

    BitmapFont fontBitmapSmall()
    {
        return fontColorBitmap(defaultFontColor, FontSize.small);
    }

    BitmapFont fontColorBitmapLarge(RGBA color)
    {
        return fontColorBitmap(color, FontSize.large);
    }

    BitmapFont fontColorBitmapSmall(RGBA color)
    {
        return fontColorBitmap(color, FontSize.small);
    }

    float fontMaxHeight(string name = defaultFontName, uint size = FontSize.medium)
    {
        if (!hasFont(size, name))
        {
            return 1;
        }
        auto currFont = font(size, name);
        return currFont.getMaxHeight;
    }

    import api.math.geom2.vec2 : Vec2f;

    Vec2f rem(uint size = FontSize.medium, string name = defaultFontName)
    {
        return rem(defaultFontColor, size, name);
    }

    Vec2f rem(RGBA color, uint size = FontSize.medium, string name = defaultFontName)
    {
        enum defaultSize = 1;
        auto bitmapPtr = hasColorBitmapUnsafe(color, size, name);
        if (!bitmapPtr)
        {
            return Vec2f(defaultSize, defaultSize);
        }
        float glyphW = (*bitmapPtr).e0.geometry.width;
        float glyphH = (*bitmapPtr).e0.geometry.height;
        float eW = glyphW != 0 ? glyphW : defaultSize;
        float eH = glyphH != 0 ? glyphH : defaultSize;

        return Vec2f(eW, eH);
    }

    override void dispose()
    {
        super.dispose;
        //TODO check if font\fontBitmap in fontCache
        foreach (cache; fontCaches)
        {
            cache.dispose;
        }
    }
}
