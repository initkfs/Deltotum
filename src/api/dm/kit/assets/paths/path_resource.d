module api.dm.kit.assets.paths.path_resource;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.core.loggers.logging : Logging;

class PathResource : LoggableUnit
{
    protected
    {
        const string _resourcePath;
    }

    bool isChangeAbsolutePaths;

    string delegate(string) resourceDirPathResolver;

    this(Logging logging, string resourcePath = null) pure @safe
    {
        super(logging);
        this._resourcePath = resourcePath;
    }

    this(const Logging logging, const string resourcePath = null) const pure @safe
    {
        super(logging);
        this._resourcePath = resourcePath;
    }

    this(immutable Logging logging, immutable string resourcePath = null) immutable pure @safe
    {
        super(logging);
        this._resourcePath = resourcePath;
    }

    bool hasResource() => _resourcePath.length > 0;

    string resourcePath() const
    {
        if (resourceDirPathResolver)
        {
            immutable string mustBeResDir = resourceDirPathResolver(_resourcePath);
            return mustBeResDir.length > 0 ? mustBeResDir : null;
        }

        return _resourcePath;
    }

    string withResourcePath(string path) const
    {
        import std.path : buildPath, isAbsolute;

        if (path.isAbsolute && !isChangeAbsolutePaths)
        {
            return path;
        }

        if (_resourcePath.length == 0)
        {
            return null;
        }

        return buildPath(_resourcePath, path);
    }

    string withResourcePaths(string[] paths...) const
    {
        auto mustBeResDir = resourcePath;
        if (mustBeResDir.length == 0)
        {
            return null;
        }

        import std.path : buildPath;
        import std.range : only, chain;

        auto resourcePath = mustBeResDir.only.chain(paths).buildPath;
        return resourcePath;
    }

    string fileResource(string[] paths...) const
    {
        import std.file : exists, isFile;

        const mustBeResourcePath = withResourcePaths(paths);
        if (mustBeResourcePath.length == 0)
        {
            return mustBeResourcePath;
        }

        if (mustBeResourcePath.exists && mustBeResourcePath.isFile)
        {
            return mustBeResourcePath;
        }

        return null;
    }

    string dirResource(string[] paths...) const
    {
        import std.file : exists, isDir;

        const mustBeResourcePath = withResourcePaths(paths);
        if (mustBeResourcePath.length == 0)
        {
            return mustBeResourcePath;
        }

        if (mustBeResourcePath.exists && mustBeResourcePath.isDir)
        {
            return mustBeResourcePath;
        }

        return null;
    }
}
