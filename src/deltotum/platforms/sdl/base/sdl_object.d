module deltotum.platforms.sdl.base.sdl_object;

import deltotum.platforms.object.platform_object : PlatformObject;
import deltotum.platforms.sdl.base.sdl_type_converter : SdlTypeConverter;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlObject : PlatformObject
{
    protected
    {
        SdlTypeConverter typeConverter;
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
