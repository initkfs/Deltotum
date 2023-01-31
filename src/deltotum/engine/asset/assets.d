module deltotum.engine.asset.assets;

import deltotum.core.application.components.units.simple_unit : SimpleUnit;
import deltotum.core.application.components.units.services.loggable_unit : LoggableUnit;

import std.experimental.logger : Logger;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

import deltotum.engine.asset.fonts.font : Font;
import deltotum.engine.ui.texts.fonts.bitmap.bitmap_font : BitmapFont;

/**
 * Authors: initkfs
 */
class Assets : LoggableUnit
{
    string assetsDirPath;

    Font defaultFont;
    BitmapFont defaultBitmapFont;

    this(Logger logger, string assetsDirPath)
    {
        super(logger);

        if (assetsDirPath.length == 0)
        {
            throw new Exception("Assets directory must not be empty");
        }
        this.assetsDirPath = assetsDirPath;
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
}
