module deltotum.asset.asset_manager;

import deltotum.application.components.units.simple_unit : SimpleUnit;
import deltotum.application.components.units.service.loggable_unit : LoggableUnit;

import std.experimental.logger : Logger;

import std.path : buildPath, dirName;
import std.file : exists, isDir, isFile;

import std.stdio;

/**
 * Authors: initkfs
 */
class AssetManager : LoggableUnit
{
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
}
