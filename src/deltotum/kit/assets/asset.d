module deltotum.kit.assets.asset;

import deltotum.core.apps.units.services.loggable_unit : LoggableUnit;

import std.logger : Logger;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

import deltotum.kit.assets.fonts.font : Font;
import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.core.resources.resource : Resource;

/**
 * Authors: initkfs
 */
class Asset : Resource
{
    Font font;
    BitmapFont fontBitmap;
    Texture[RGBA] fontCache;

    this(Logger logger, string assetsDir)
    {
        super(logger, assetsDir);
    }

    bool addCachedFont(RGBA color, Texture fontTexture)
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

    string image(string path)
    {
        auto mustBeImagePath = withResourceDir(path);
        if (mustBeImagePath.isNull)
        {
            throw new Exception("Not found image in resources: " ~ path);
        }
        return mustBeImagePath.get;
    }

    Font newFont(string fontFilePath, int size)
    {
        auto mustBeFontPath = withResourceDir(fontFilePath);
        if(mustBeFontPath.isNull){
            throw new Exception("Not found font in resources: " ~ fontFilePath);
        }
        Font nFont = new Font(logger, mustBeFontPath.get, size);
        return nFont;
    }

    void destroy()
    {
        if (font)
        {
            font.destroy;
        }
        if (fontBitmap)
        {
            fontBitmap.destroy;
        }

        //TODO check if font\fontBitmap in fontCache
        foreach (fontTexture; fontCache)
        {
            fontTexture.destroy;
        }
    }
}
