module deltotum.kit.assets.asset;

import deltotum.core.apps.units.simple_unit : SimpleUnit;
import deltotum.core.apps.units.services.loggable_unit : LoggableUnit;

import std.logger : Logger;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

import deltotum.kit.assets.fonts.font : Font;
import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;
import deltotum.kit.graphics.colors.rgba: RGBA;
import deltotum.kit.sprites.textures.texture: Texture;

/**
 * Authors: initkfs
 */
class Asset : LoggableUnit
{
    string assetsDirPath;

    Font defaultFont;
    BitmapFont defaultBitmapFont;

    Texture[RGBA] fontCache;

    this(Logger logger, string assetsDirPath)
    {
        super(logger);

        if (assetsDirPath.length == 0)
        {
            throw new Exception("Assets directory must not be empty");
        }
        this.assetsDirPath = assetsDirPath;
    }

    bool addCachedFont(RGBA color, Texture fontTexture)
    {
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

    string filePath(string path)
    {
        immutable filePath = buildPath(assetsDirPath, path);
        return filePath;
    }

    string image(string path)
    {
        const string imagePath = filePath(path);
        return imagePath;
    }

    Font font(string fontFilePath, int size)
    {
        const string path = filePath(fontFilePath);
        Font font = new Font(logger, path, size);
        return font;
    }

    void destroy()
    {
        if (defaultFont)
        {
            defaultFont.destroy;
        }
        if (defaultBitmapFont)
        {
            defaultBitmapFont.destroy;
        }
    }
}