module deltotum.sys.base.sys_lib;

import Loader = bindbc.loader;

/**
 * Authors: initkfs
 */
abstract class SysLib
{
    enum InvalidLib : int
    {
        noLibrary = -1,
        badLibrary = -2
    }

    protected
    {
        Loader.SharedLib _handle;
        int _loadedVersion = InvalidLib.noLibrary;

        abstract
        {
            int needVersion();
            const(char[][]) libPaths();
            void bindSymbols();
        }
    }

    void delegate() onBeforeLoad;
    void delegate() onAfterLoad;
    void delegate() onBeforeUnload;
    void delegate() onAfterUnload;

    void delegate() onNoLibrary;
    void delegate() onBadLibrary;

    void delegate(const(char*), const(char*)) onErrorWithMessage;

    bool initialize()
    {
        return false;
    }

    bool unload() 
    {
        if (!isLoaded)
        {
            return false;
        }

        if (onBeforeUnload)
        {
            onAfterUnload();
        }

        Loader.unload(_handle);

        if (onAfterUnload)
        {
            onAfterUnload();
        }

        return true;
    }

    bool isLoaded()  
    {
        return _loadedVersion == needVersion;
    }

    int loadedVersion()  
    {
        return _loadedVersion;
    }

    void bind(void** ptr, const(char)* symbolName)
    {
        Loader.bindSymbol(_handle, ptr, symbolName);
    }

    void load() 
    {
        if (onBeforeLoad)
        {
            onBeforeLoad();
        }

        foreach (path; libPaths)
        {
            if (loadFromPath(path.ptr))
            {
                if (onAfterLoad && isLoaded)
                {
                    onAfterLoad();
                }
                break;
            }
        }
    }

    bool loadFromPath(const(char)* libPath) 
    {
        auto mustBeLib = Loader.load(libPath);
        if (mustBeLib == Loader.invalidHandle)
        {
            _loadedVersion = InvalidLib.noLibrary;
            if (onNoLibrary)
            {
                onNoLibrary();
            }
            return false;
        }

        _handle = mustBeLib;

        Loader.resetErrors;

        bindSymbols;

        if (Loader.errorCount() != 0)
        {
            _loadedVersion = InvalidLib.badLibrary;
            if (onBadLibrary)
            {
                onBadLibrary();
            }

            if (onErrorWithMessage)
            {
                foreach (err; Loader.errors)
                {
                    onErrorWithMessage(err.error, err.message);
                }
            }

            return false;
        }

        _loadedVersion = needVersion;
        return true;
    }
}
