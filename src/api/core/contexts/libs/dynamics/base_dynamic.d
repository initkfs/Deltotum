module api.core.contexts.libs.dynamics.base_dynamic;

/**
 * Authors: initkfs
 */

version (linux)
{
    import core.sys.posix.dlfcn;

    bool open(const(char)* name, out void* handle, int flags = RTLD_NOW | RTLD_LOCAL | RTLD_DEEPBIND)
    {
        if (void* handlePtr = dlopen(name, flags))
        {
            handle = handlePtr;
            return true;
        }
        return false;
    }

    bool close(void* lib)
    {
        //TODO flags RTLD_NODELETE (glibc > 2.2)
        int ret = dlclose(lib);
        if (ret != 0)
        {
            return false;
        }
        return true;
    }

    bool bind(void* lib, const(char)* symbolName, out void* symbolPtr)
    {
        if (void* ptr = dlsym(lib, symbolName))
        {
            symbolPtr = ptr;
            return true;
        }

        return false;
    }

    bool error(out string errorText)
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
    static assert(0, "Not supported shared loading");
}
