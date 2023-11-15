module dm.sys.sdl.base.sdl_object;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.platforms.objects.com_object : ComObject;
import dm.sys.sdl.base.sdl_type_converter : SdlTypeConverter;

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

    const(char[]) getError() const @nogc nothrow
    {
        const char* errorPtr = SDL_GetError();
        const err = ptrToError(errorPtr);
        return err;
    }

    protected const(char[]) ptrToError(const char* errorPtr) const @nogc nothrow
    {
        if (errorPtr is null)
        {
            return "Cannot get error from pointer: pointer is null";
        }
        const(char[]) error = errorPtr.fromStringz;
        return error;
    }

    bool clearError() const @nogc nothrow
    {
        SDL_ClearError();
        return true;
    }
}
