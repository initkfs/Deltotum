module deltotum.asset.asset_manager;

import deltotum.application.components.units.simple_unit : SimpleUnit;
import deltotum.application.components.units.service.loggable_unit : LoggableUnit;

import std.experimental.logger : Logger;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

import deltotum.asset.fonts.font : Font;
import deltotum.ui.texts.fonts.bitmap.bitmap_font: BitmapFont;

/**
 * Authors: initkfs
 */
class AssetManager : LoggableUnit
{
    @property Font defaultFont;
    @property BitmapFont defaultBitmapFont;

    this(Logger logger)
    {
        super(logger);
    }

    string assetsDirPath()
    {
        import std.file : thisExePath;

        //TODO move to config
        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(thisExePath.dirName, assetsDirPath);
        if (exists(assetsDir) && isDir(assetsDir))
        {
            return assetsDir;
        }
        //TODO or exception?
        logger.errorf("Unable to find resource directory: %s.", assetsDir);
        return null;
    }

    string filePath(string path)
    {
        immutable assetsDir = assetsDirPath;
        if (assetsDir.length == 0)
        {
            logger.errorf("Unable to load resource path %s, resource directory is null", path);
            return null;
        }

        immutable filePath = buildPath(assetsDir, path);
        if (filePath.exists && filePath.isFile)
        {
            return filePath;
        }

        logger.errorf("Unable to load resource %s, file does not exist or is not a file", filePath);
        return null;
    }

    Font font(string fontFilePath, int size)
    {
        const path = filePath(fontFilePath);
        Font font = new Font(path, size);
        return font;
    }
}
