module dm.back.sdl2.base.sdl_object;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.platforms.objects.com_object : ComObject;
import dm.com.platforms.results.com_result : ComResult;
import dm.back.sdl2.base.sdl_type_converter : SdlTypeConverter;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlObject : ComObject
{
    protected
    {
        SdlTypeConverter typeConverter;
    }

    this(SdlTypeConverter typeConverter = null) pure @safe
    {
        this.typeConverter = typeConverter !is null ? typeConverter : new SdlTypeConverter;
    }

    invariant
    {
        assert(typeConverter !is null);
    }

    ComResult getErrorRes(int code = -1, string message = null) const nothrow
    {
        return message ? ComResult.error(code, message, getError) : ComResult.error(code, getError);
    }

    string getError() const nothrow
    {
        const char* errorPtr = SDL_GetError();
        const err = ptrToStr(errorPtr);
        return err;
    }

    protected string ptrToStr(const char* errorPtr) const nothrow
    {
        if (!errorPtr)
        {
            return "";
        }
        const error = errorPtr.fromStringz.idup;
        return error;
    }

    bool clearError() const nothrow
    {
        SDL_ClearError();
        return true;
    }
}
