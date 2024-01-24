module dm.kit.assets.asset;

import dm.core.units.services.loggable_unit : LoggableUnit;

import std.logger : Logger;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

import dm.com.graphics.com_font : ComFont;
import dm.kit.assets.fonts.font : Font;
import dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.sprites.textures.texture : Texture;
import dm.core.resources.resource : Resource;

/**
 * Authors: initkfs
 */
class Asset : Resource
{
    ComFont delegate(string fontPath, int fontSize) comFontProvider;

    Font font;
    BitmapFont fontBitmap;
    Texture[RGBA] fontCache;

    string defaultImagesResourceDir = "images";
    string defaultFontResourceDir = "fonts";

    this(Logger logger, string assetsDir, ComFont delegate(string fontPath, int fontSize) comFontProvider) pure @safe
    {
        super(logger, assetsDir);
        import std.exception : enforce;

        enforce(comFontProvider, "Font provider must not be null");
        this.comFontProvider = comFontProvider;
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
            throw new Exception("Not found font in resources: " ~ fontFile);
        }
        return mustBeFontPath.get;
    }

    Font newFont(string fontFilePath, int size)
    {
        const path = fontPath(fontFilePath);
        auto comFont = comFontProvider(path, size);
        Font nFont = new Font(logger, comFont);
        nFont.initialize;
        logger.trace("Create new font from ", path);
        return nFont;
    }

    bool addCachedFont(RGBA color, Texture fontTexture) @safe
    {
        if (fontTexture is fontBitmap)
        {
            throw new Exception("Main bitmap font cannot be cached");
        }

        if (color in fontCache)
        {
            return false;
        }
        fontCache[color] = fontTexture;
        return true;
    }

    Texture cachedFont(RGBA color)
    {
        if (auto cachePtr = color in fontCache)
        {
            return *cachePtr;
        }
        return null;
    }

    override void dispose()
    {
        super.dispose;
        if (font && !fontBitmap.isDisposed)
        {
            font.dispose;
        }
        if (fontBitmap && !fontBitmap.isDisposed)
        {
            fontBitmap.dispose;
        }

        //TODO check if font\fontBitmap in fontCache
        foreach (fontTexture; fontCache)
        {
            if (fontTexture.isCreated && !fontTexture.isDisposed)
            {
                fontTexture.dispose;
            }
        }
    }
}