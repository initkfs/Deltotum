module api.core.utils.libs.dynamics.dynamic_loader;

struct DynLib
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

version (linux)
{
    import core.sys.posix.dlfcn;

    bool libLoad(const(char)* name, out void* handle)
    {
        //void* handle = dlmopen(LM_ID_NEWLM, "libfoo.so", RTLD_NOW);
        //RTLD_DEEPBIND
        if (void* handlePtr = dlopen(name, RTLD_NOW | RTLD_LOCAL | RTLD_DEEPBIND))
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
class DynamicLoader
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
        DynLib lib;
    }

    abstract
    {
        const(char[][]) libPaths();
        void bindAll();
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

    bool bind(void* funcPtr, const(char)[] name, bool isCheckError = true)
    {
        return bindT(funcPtr, name, isCheckError);
    }

    bool bind(shared void* funcPtr, const(char)[] name, bool isCheckError = true)
    {
        return bindT(funcPtr, name, isCheckError);
    }

    bool bindT(T)(T funcPtr, const(char)[] name, bool isCheckError = true)
    {
        if (!isLoad)
        {
            return false;
        }

        void* mustBePtr;
        if (libBind(lib.handlePtr, name.ptr, mustBePtr))
        {
            //TODO or cast(shared(...))?
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
        if (!lib.isLoad)
        {
            return false;
        }

        if (onBeforeUnload)
        {
            onAfterUnload();
        }

        if (!libUnload(lib.handlePtr))
        {
            checkError("Error unloading library: " ~ lib.toString);
            return false;
        }

        if (onAfterUnload)
        {
            onAfterUnload();
        }

        return true;
    }

    bool isLoad() => lib.isLoad;

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

        if (!isLoad)
        {
            import std.conv : text;

            errors ~= text("Not found library ", libPaths);
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

        if (onLoad)
        {
            onLoad();
        }

    }

    bool loadFromPath(const(char)[] libPath, bool isCheckError = false)
    {
        import std.string : toStringz;
        import std.conv : to;

        lib = DynLib.init;

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

        lib = DynLib(handle, libPath, 0, true);

        bindAll;

        return true;
    }

}
