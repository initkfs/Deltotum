module api.dm.back.sdl3.base.sdl_object;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.objects.com_object : ComObject;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.base.sdl_type_converter : SdlTypeConverter;

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

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

    ComResult getErrorRes(int code = -1) const nothrow
    {
        return ComResult.error(code, null, getError);
    }

    ComResult getErrorRes(string message) const nothrow
    {
        return ComResult.error(-1, message, getError);
    }

    ComResult getErrorRes(int code, string message) const nothrow
    {
        return ComResult.error(code, message, getError);
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
