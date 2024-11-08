module api.dm.kit.assets.asset;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.core.loggers.logging : Logging;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;
import std.typecons : Nullable;

import std.stdio;

import api.dm.com.graphics.com_font : ComFont;
import api.dm.kit.assets.fonts.font : Font;
import api.dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.textures.texture : Texture;
import api.core.resources.locals.local_resources: LocalResources;
import api.dm.kit.assets.fonts.font_cache : FontCache;
import api.dm.kit.assets.fonts.font_size : FontSize;

/**
 * Authors: initkfs
 */
class Asset : LocalResources
{
    ComFont delegate() comFontProvider;

    enum defaultFontName = "DMDefaultFont";

    RGBA defaultFontColor;
    BitmapFont defaultFontBitmap;

    protected
    {
        FontCache[string] fontCaches;
    }

    string defaultImagesResourceDir = "images";
    string defaultFontResourceDir = "fonts";

    this(Logging logging, string assetsDir, ComFont delegate() comFontProvider) pure @safe
    {
        super(logging, assetsDir);
        import std.exception : enforce;

        enforce(comFontProvider, "Font provider must not be null");
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
        if (mustBeImagePath.isNull)
        {
            throw new Exception("Not found image in resources: " ~ imageFile);
        }

        return mustBeImagePath.get;
    }

    string fontPath(string fontFile) const
    {
        import std.path : isAbsolute;

        if (fontFile.isAbsolute)
        {
            return fontFile;
        }

        auto mustBeFontPath = fileResource(defaultFontResourceDir, fontFile);
        if (mustBeFontPath.isNull)
        {
            import std.format : format;

            throw new Exception(format("Not found font file %s in resources dir %s", fontFile, defaultFontResourceDir));
        }
        return mustBeFontPath.get;
    }

    Font newFont(string fontFilePath, size_t size)
    {
        const path = fontPath(fontFilePath);
        auto comFont = comFontProvider();
        if (const err = comFont.load(path, size))
        {
            throw new Exception(err.toString);
        }
        Font nFont = new Font(logging, comFont);
        nFont.initialize;
        logger.trace("Create new font from ", path);
        return nFont;
    }

    bool hasFont(string name = defaultFontName, size_t size = FontSize.medium)
    {
        if (auto fontCachePtr = name in fontCaches)
        {
            return (*fontCachePtr).hasFont(size) !is null;
        }

        return false;
    }

    bool hasLargeFont(string name = defaultFontName) => hasFont(name, FontSize.large);
    bool hasSmallFont(string name = defaultFontName) => hasFont(name, FontSize.small);

    void addFont(Font font, size_t size = FontSize.medium, string name = defaultFontName)
    {
        fontCaches[name].addFont(size, font);
    }

    void addFontSmall(Font font, string name = defaultFontName)
    {
        addFont(font, FontSize.small, name);
    }

    void addFontLarge(Font font, string name = defaultFontName)
    {
        addFont(font, FontSize.large, name);
    }

    Font font(size_t size = FontSize.medium, string name = defaultFontName)
    {
        auto cachedFont = fontCaches[name].font(size);
        assert(cachedFont);
        return cachedFont;
    }

    Font fontSmall(string name = defaultFontName)
    {
        return font(FontSize.small, name);
    }

    Font fontLarge(string name = defaultFontName)
    {
        return font(FontSize.large, name);
    }

    void addFontColorBitmap(BitmapFont fontTexture, RGBA color, size_t size = FontSize.medium, string name = defaultFontName)
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

    bool hasColorBitmap(RGBA color, size_t size = FontSize.medium, string name = defaultFontName)
    {
        auto fontCache = fontCaches[name];
        return fontCache.hasBitmap(size, color) !is null;
    }

    BitmapFont fontColorBitmap(RGBA color, size_t size = FontSize.medium, string name = defaultFontName)
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

    BitmapFont fontBitmap(size_t size = FontSize.medium, string name = defaultFontName)
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
