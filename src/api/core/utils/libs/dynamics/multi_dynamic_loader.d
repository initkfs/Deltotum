module api.core.utils.libs.dynamics.multi_dynamic_loader;

import api.core.utils.libs.dynamics.dynamic_loader;

/**
 * Authors: initkfs
 */

//TODO : DynamicLoader
class MultiDynamicLoader
{
    string workDirPath;

    void delegate() onBeforeLoad;
    void delegate() onLoad;

    void delegate(string) onLoadErrors;

    void delegate() onBeforeUnload;
    void delegate() onAfterUnload;

    string[] errors;

    bool isChangeCwd = true;

    protected
    {
        DynLib[] libs;

    }

    bool isLoad;

    abstract
    {
        const(char[][]) libPaths();
        void bindAll(const(char)[] name, ref DynLib lib);
    }

    int libVersion() => 0;

    string libVersionStr()
    {
        import std.conv : to;

        return libVersion.to!string;
    }

    bool checkError(string message = null)
    {
        string err;
        if (libError(err))
        {
            errors ~= message.length > 0 ? (message ~ err) : (err);
            return true;
        }
        return false;
    }

    bool bind(ref DynLib lib, void* funcPtr, const(char)[] name, bool isCheckError = true)
    {
        return bindT(lib, funcPtr, name, isCheckError);
    }

    bool bind(ref DynLib lib, shared void* funcPtr, const(char)[] name, bool isCheckError = true)
    {
        return bindT(lib, funcPtr, name, isCheckError);
    }

    bool bindT(T)(ref DynLib lib, T funcPtr, const(char)[] name, bool isCheckError = true)
    {
        void* mustBePtr;
        if (libBind(lib.handlePtr, name.ptr, mustBePtr))
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

    bool unload()
    {
        if (!isLoad)
        {
            return false;
        }

        if (onBeforeUnload)
        {
            onAfterUnload();
        }

        foreach (ref DynLib l; libs)
        {
            if (!libUnload(l.handlePtr))
            {
                errors ~= "Error unloading library: " ~ l.toString;
                return false;
            }
        }

        if (onAfterUnload)
        {
            onAfterUnload();
        }

        return true;
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
            if (!loadPath.isAbsolute)
            {
                auto cwdDir = workDirPath ? workDirPath : lastWorkDir;
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
            }
        }

        if (currentLoad == needLoad)
        {
            isLoad = true;
        }

        if (errors.length > 0)
        {
            if (onLoadErrors)
            {
                foreach (err; errors)
                {
                    onLoadErrors(err);
                }
            }
            else
            {
                import std.conv : text;

                throw new Exception(text("Library loading error: ", errors));
            }

            return isLoad;
        }

        if (onLoad)
        {
            onLoad();
        }

        return isLoad;
    }

    bool loadFromPath(const(char)[] libPath, bool isCheckError = false)
    {
        import std.string : toStringz;
        import std.conv : to;

        void* handle;
        if (!libLoad(libPath.toStringz, handle))
        {
            if (isCheckError)
            {
                import std.conv : to;

                checkError(("Error loading library from path: " ~ libPath).to!string);
            }
            return false;
        }

        auto newLib = DynLib(handle, libPath, 0, true);
        libs ~= newLib;

        import std.path : baseName;

        bindAll(libPath.baseName, newLib);

        return true;
    }
}
