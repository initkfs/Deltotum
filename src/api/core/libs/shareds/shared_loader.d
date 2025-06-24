module api.core.libs.shareds.shared_loader;

struct SharedLib
{
    void* handlePtr;
    const(char)[] name;
    int loadVersion;
    bool _load;

    bool isLoad() const @nogc pure @safe => _load && handlePtr;

    string toString() const
    {
        import std.format : format;

        return format("'%s', %s, is load: %s", name, loadVersion, isLoad);
    }
}

version (Posix)
{
    import core.sys.posix.dlfcn;

    bool libLoad(const(char)* name, out void* handle)
    {
        //RTLD_DEEPBIND
        if (void* handlePtr = dlopen(name, RTLD_NOW))
        {
            handle = handlePtr;
            return true;
        }
        return false;
    }

    bool libUnload(void* lib)
    {
        int ret = dlclose(lib);
        if (ret != 0)
        {
            return false;
        }
        return true;
    }

    bool libBind(void* lib, const(char)* symbolName, out void* symbolPtr)
    {
        if (void* ptr = dlsym(lib, symbolName))
        {
            symbolPtr = ptr;
            return true;
        }

        return false;
    }

    bool libError(out string errorText)
    {
        const char* errPtr = dlerror();
        if (!errPtr)
        {
            return false;
        }
        import std.string : fromStringz;

        errorText = errPtr.fromStringz.idup;
        return true;
    }
}
else
{
    static assert(0, "Not supported shared loaders");
}

/**
 * Authors: initkfs
 */
class SharedLoader
{
    string workDirPath;

    void delegate() onBeforeLoad;
    void delegate() onLoad;

    void delegate(string) onLoadErrors;

    void delegate() onBeforeUnload;
    void delegate() onAfterUnload;

    string[] errors;

    protected
    {
        SharedLib sharedLib;
    }

    abstract
    {
        const(char[][]) libPaths();
        void bindAll();
    }

    int libVersion() => 0;

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

    bool bind(void** funcPtr, const(char)[] name, bool isCheckError = true)
    {
        if (!isLoad)
        {
            return false;
        }

        void* mustBePtr;
        if (libBind(sharedLib.handlePtr, name.ptr, mustBePtr))
        {
            *funcPtr = mustBePtr;
            return true;
        }

        if (isCheckError)
        {
            checkError;
        }
        return false;
    }

    bool unload()
    {
        if (!sharedLib.isLoad)
        {
            return false;
        }

        if (onBeforeUnload)
        {
            onAfterUnload();
        }

        if (!libUnload(sharedLib.handlePtr))
        {
            checkError("Error unloading library: " ~ sharedLib.toString);
            return false;
        }

        if (onAfterUnload)
        {
            onAfterUnload();
        }

        return true;
    }

    bool isLoad() => sharedLib.isLoad;

    void load()
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

        foreach (path; libPaths)
        {
            if (!path.isAbsolute)
            {
                auto cwdDir = workDirPath ? workDirPath : lastWorkDir;
                auto cwdPath = buildPath(cwdDir, path);

                version (Posix)
                {
                    //TODO check symlink
                    if (cwdPath.exists)
                    {
                        import std.path : dirName;
                        import std.file : chdir, readLink;

                        auto newCwd = cwdPath.readLink.dirName;
                        isChangeWorkDir = true;
                        if (!workDirPath)
                        {
                            workDirPath = newCwd;
                        }
                        chdir(newCwd);
                    }
                }

                if (loadFromPath(cwdPath))
                {
                    break;
                }
            }

            if (loadFromPath(path))
            {
                break;
            }
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
            return;
        }

        if (!isLoad)
        {
            errors ~= "Not found library";
            return;
        }

        if (onLoad)
        {
            onLoad();
        }

    }

    bool loadFromPath(const(char)[] libPath, bool isCheckError = false)
    {
        import std.string : toStringz;
        import std.conv : to;

        sharedLib = SharedLib.init;

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

        sharedLib = SharedLib(handle, libPath, 0, true);

        bindAll;

        return true;
    }

}
