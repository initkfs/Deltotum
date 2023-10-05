module deltotum.core.resources.resource;

import deltotum.core.apps.units.services.loggable_unit : LoggableUnit;

import std.logger : Logger;
import std.typecons : Nullable;

class Resource : LoggableUnit
{
    protected
    {
        const string _resourcesDir;
    }

    this(Logger logger, string resourcesDir = null)
    {
        super(logger);
        if (resourcesDir !is null)
        {
            import std.file : exists, isDir;

            if (!resourcesDir.exists)
            {
                throw new Exception(
                    "Application resources directory does not exist: " ~ resourcesDir);
            }

            if (!resourcesDir.isDir)
            {
                throw new Exception(
                    "Application resources directory is not a directory: " ~ resourcesDir);
            }

            this._resourcesDir = resourcesDir;
        }
    }

    Nullable!string resourcesDir() const
    {
        if (!_resourcesDir)
        {
            return Nullable!string.init;
        }
        return Nullable!string(_resourcesDir);
    }

    Nullable!string withResourceDir(string path) const
    {
        import std.path : buildPath, isAbsolute;

        if (path.isAbsolute)
        {
            return Nullable!string(path);
        }

        Nullable!string mustBePath = buildPath(_resourcesDir, path);
        return mustBePath;
    }

    Nullable!string withResourcePaths(string[] paths...) const
    {
        if (_resourcesDir.length == 0)
        {
            return Nullable!string.init;
        }

        import std.path : buildPath;
        import std.range : only, chain;

        auto resourcePath = _resourcesDir.only.chain(paths).buildPath;
        return Nullable!string(resourcePath);
    }

    Nullable!string fileResource(string[] paths...) const
    {
        import std.file : exists, isFile;

        const mustBeResourcePath = withResourcePaths(paths);
        if (mustBeResourcePath.isNull)
        {
            return mustBeResourcePath;
        }

        const resourcePath = mustBeResourcePath.get;
        if (resourcePath.exists && resourcePath.isFile)
        {
            return Nullable!string(resourcePath);
        }

        return Nullable!string.init;
    }

    Nullable!string dirResource(string[] paths...) const
    {
        import std.file : exists, isDir;

        const mustBeResourcePath = withResourcePaths(paths);
        if (mustBeResourcePath.isNull)
        {
            return mustBeResourcePath;
        }

        const resourcePath = mustBeResourcePath.get;

        if (resourcePath.exists && resourcePath.isDir)
        {
            return Nullable!string(resourcePath);
        }

        return Nullable!string.init;
    }
}
