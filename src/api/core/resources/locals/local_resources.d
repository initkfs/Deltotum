module api.core.resources.locals.local_resources;

import api.core.components.units.services.loggable_unit : LoggableUnit;

import api.core.loggers.logging : Logging;

class LocalResources : LoggableUnit
{
    protected
    {
        const string _resourcesDir;
    }

    bool isChangeAbsolutePaths;

    string delegate(string) resourceDirPathResolver;

    this(Logging logging, string resourcesDir = null) pure @safe
    {
        super(logging);
        this._resourcesDir = resourcesDir;
    }

    this(const Logging logging, const string resourcesDir = null) const pure @safe
    {
        super(logging);
        this._resourcesDir = resourcesDir;
    }

    this(immutable Logging logging, immutable string resourcesDir = null) immutable pure @safe
    {
        super(logging);
        this._resourcesDir = resourcesDir;
    }

    bool hasResourcesDir() => resourcesDir.length > 0;

    string resourcesDir() const
    {
        if (resourceDirPathResolver)
        {
            immutable string mustBeResDir = resourceDirPathResolver(_resourcesDir);
            return mustBeResDir.length > 0 ? mustBeResDir : null;
        }

        return _resourcesDir;
    }

    string withResourceDir(string path) const
    {
        import std.path : buildPath, isAbsolute;

        if (path.isAbsolute && !isChangeAbsolutePaths)
        {
            return path;
        }

        if (_resourcesDir.length == 0)
        {
            return null;
        }

        return buildPath(_resourcesDir, path);
    }

    string withResourcePaths(string[] paths...) const
    {
        auto mustBeResDir = resourcesDir;
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
