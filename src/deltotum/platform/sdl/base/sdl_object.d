module deltotum.platform.sdl.base.sdl_object;

import deltotum.platform.object.platform_object : PlatformObject;
import deltotum.platform.sdl.base.sdl_type_converter : SdlTypeConverter;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlObject : PlatformObject
{
    protected
    {
        SdlTypeConverter typeConverter = new SdlTypeConverter;
    }

    invariant
    {
        assert(typeConverter !is null);
    }

    string getError() const nothrow
    {
        const char* errorPtr = SDL_GetError();
        const string err = ptrToError(errorPtr);
        return err;
    }

    protected string ptrToError(const char* errorPtr) const nothrow
    {
        if (errorPtr is null)
        {
            return "Cannot get error from pointer: pointer is null";
        }
        const string error = errorPtr.fromStringz.idup;
        return error;
    }

    bool clearError() const @nogc nothrow
    {
        SDL_ClearError();
        return true;
    }
}
