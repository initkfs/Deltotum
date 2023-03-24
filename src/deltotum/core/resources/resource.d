module deltotum.core.resources.resource;

import std.typecons : Nullable;

class Resource
{
    const string resourcesDir;

    this(string resourcesDir = null)
    {
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

            this.resourcesDir = resourcesDir;
        }
    }

    Nullable!string withResourcePaths(string[] paths) const
    {
        if (resourcesDir.length == 0)
        {
            return Nullable!string.init;
        }

        import std.path : buildPath;
        import std.range : only, chain;

        auto resourcePath = resourcesDir.only.chain(paths).buildPath;
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
