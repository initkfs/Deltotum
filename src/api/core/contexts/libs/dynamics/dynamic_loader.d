module api.core.contexts.libs.dynamics.dynamic_loader;

import BaseDynamic = api.core.contexts.libs.dynamics.base_dynamic;

struct DynLib
{
    void* handle;
    string name;
    string path;
    int lversion;
}

/**
 * Authors: initkfs
 */
class DynamicLoader
{
    string workDirPath;
    bool isChangeCwd = true;
    bool isLocalPath;

    void delegate() onBeforeLoad;
    void delegate() onLoad;

    bool isUnloadOnErrors = true;
    bool isExceptionOnErrors;

    void delegate(string[]) onErrors;
    void delegate(string) onErrorsStr;

    bool isLoadOneLib;

    void delegate() onBeforeUnload;
    void delegate() onUnload;

    string[] errors;

    protected
    {
        DynLib[] libs;
    }

    abstract
    {
        string[] libPaths();
    }

    void bindAll()
    {

    }

    void bindAll(ref DynLib lib)
    {

    }

    bool bind(void* funcPtr, const(char)[] name, bool isCheckError = true)
    {
        if (libs.length != 1)
        {
            import std.conv : to;

            throw new Exception("Bind without libs, but libs count not 1: " ~ libs
                    .length.to!string);
        }
        return bind(libs[0], funcPtr, name, isCheckError);
    }

    bool bind(ref DynLib lib, void* funcPtr, const(char)[] name, bool isCheckError = true)
    {
        void* mustBePtr;
        if (BaseDynamic.bind(lib.handle, name.ptr, mustBePtr))
        {
            //TODO or cast(shared(...))?
            if (!mustBePtr)
            {
                import std.conv : text;

                errors ~= text("Bind null pointer: ", name);
                return false;
            }

            *(cast(void**) funcPtr) = mustBePtr;
            return true;
        }
        else
        {
            import std.conv : text;

            errors ~= text("Not found symbol: ", name);
        }

        if (isCheckError)
        {
            checkError;
        }
        return false;
    }

    bool load()
    {
        if (onBeforeLoad)
        {
            onBeforeLoad();
        }

        errors = null;

        import std.path : isAbsolute, buildPath;
        import std.file : getcwd, exists, chdir;

        auto lastWorkDir = getcwd;
        bool isChangeWorkDir;
        scope (exit)
        {
            if (isChangeWorkDir)
            {
                chdir(lastWorkDir);
            }
        }

        const needLoad = libPaths.length;
        size_t currentLoad;

        import std.conv : to;

        foreach (path; libPaths)
        {
            string loadPath = path.to!string;
            if (!loadPath.isAbsolute && isLocalPath)
            {
                auto cwdDir = workDirPath.length > 0 ? workDirPath : lastWorkDir;
                auto cwdPath = buildPath(cwdDir, path);

                if (isChangeCwd)
                {
                    version (Posix)
                    {
                        //TODO check symlink
                        if (cwdPath.exists)
                        {
                            import std.path : dirName;
                            import std.file : chdir, readLink, isSymlink;

                            auto newCwd = cwdPath.isSymlink ? cwdPath.readLink.dirName
                                : cwdPath.dirName;
                            isChangeWorkDir = true;
                            if (!workDirPath)
                            {
                                workDirPath = newCwd;
                            }
                            chdir(newCwd);
                        }
                    }
                }

                loadPath = cwdPath;
            }

            if (!loadFromPath(loadPath))
            {
                import std.conv : text;

                errors ~= text("Not found library ", loadPath);
            }
            else
            {
                currentLoad++;
                if (isLoadOneLib && currentLoad >= 1)
                {
                    break;
                }
            }
        }

        if (currentLoad != needLoad)
        {
            import std.format : format;

            errors ~= format("Need count: %d, but loaded: %d", needLoad, currentLoad);
        }

        if (needVersion != libVersion)
        {
            import std.format : format;

            errors ~= format("Need version: %d, but loaded: %d", needVersion, libVersion);
        }

        bindAll;

        if (errors.length > 0)
        {
            if (isUnloadOnErrors)
            {
                scope (exit)
                {
                    unload;
                }
            }

            if ((!onErrors) && (!onErrorsStr) && isExceptionOnErrors)
            {
                import std.conv : text;

                throw new Exception(text("Library loading error: ", errors));
            }

            if (onErrorsStr)
            {
                import std.conv : text;

                onErrorsStr(text(errors));
            }

            if (onErrors)
            {
                onErrors(errors);
            }

            return false;
        }

        if (onLoad)
        {
            onLoad();
        }

        return true;
    }

    bool loadFromPath(string libPath, bool isCheckError = false)
    {
        import std.string : toStringz;
        import std.conv : to;

        void* handle;
        if (!BaseDynamic.open(libPath.toStringz, handle))
        {
            if (isCheckError)
            {
                import std.conv : to;

                checkError(("Error loading library from path: " ~ libPath).to!string);
            }
            return false;
        }

        //TODO libnames cache
        import std.path : baseName;
        import std.string : lastIndexOf;

        auto libName = libPath.baseName;

        auto extPos = libName.lastIndexOf('.');
        if (extPos >= 0)
        {
            libName = libName[0 .. extPos];
        }

        auto newLib = DynLib(handle, libName, libPath, 0);
        libs ~= newLib;

        bindAll(newLib);

        return true;
    }

    bool unload()
    {
        if (libs.length == 0)
        {
            return true;
        }

        if (onBeforeUnload)
        {
            onBeforeUnload();
        }

        foreach (ref DynLib l; libs)
        {
            if (!l.handle)
            {
                errors ~= "Error unloading library, handle is null: " ~ l.name;
                continue;
            }

            if (!BaseDynamic.close(l.handle))
            {
                errors ~= "Error unloading library: " ~ l.name;
                checkError;
                continue;
            }
        }

        if (onUnload)
        {
            onUnload();
        }

        libs = null;

        return true;
    }

    bool checkError(string message = null)
    {
        string err;
        if (BaseDynamic.error(err))
        {
            errors ~= message.length > 0 ? (message ~ err) : (err);
            return true;
        }
        return false;
    }

    string errorsText()
    {
        import std.conv : text;

        return errors.text;
    }

    int libVersion() => 0;
    int needVersion() => 0;

    string libVersionStr()
    {
        import std.conv : to;

        return libVersion.to!string;
    }

}
