module api.core.resources.resource;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import std.logger : Logger;
import std.typecons : Nullable;

class Resource : LoggableUnit
{
    protected
    {
        const string _resourcesDir;
    }

    bool isChangeAbsolutePaths;

    string delegate(string) resourceDirPathResolver;

    this(Logger logger, string resourcesDir = null) pure @safe
    {
        super(logger);
        this._resourcesDir = resourcesDir;
    }

    this(const Logger logger, const string resourcesDir = null) const pure @safe
    {
        super(logger);
        this._resourcesDir = resourcesDir;
    }

    Nullable!string resourcesDir() const
    {
        if (resourceDirPathResolver)
        {
            immutable string mustBeResDir = resourceDirPathResolver(_resourcesDir);
            return mustBeResDir.length > 0 ? Nullable!string(mustBeResDir) : Nullable!string.init;
        }

        if (!_resourcesDir)
        {
            return Nullable!string.init;
        }

        return Nullable!string(_resourcesDir);
    }

    Nullable!string withResourceDir(string path) const
    {
        import std.path : buildPath, isAbsolute;

        if (path.isAbsolute && !isChangeAbsolutePaths)
        {
            return Nullable!string(path);
        }

        Nullable!string mustBePath = buildPath(_resourcesDir, path);
        return mustBePath;
    }

    Nullable!string withResourcePaths(string[] paths...) const
    {
        auto mustBeResDir = resourcesDir();
        if (mustBeResDir.isNull)
        {
            return mustBeResDir;
        }

        import std.path : buildPath;
        import std.range : only, chain;

        auto resourcePath = mustBeResDir.get.only.chain(paths).buildPath;
        return resourcePath.length > 0 ? Nullable!string(resourcePath) : Nullable!string.init;
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
