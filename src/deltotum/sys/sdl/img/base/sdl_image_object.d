module deltotum.sys.sdl.img.base.sdl_image_object;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.sys.sdl.base.sdl_object : SdlObject;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImageObject : SdlObject
{
    override const(char[]) getError() const nothrow
    {
        const char* errPtr = IMG_GetError();
        const error = ptrToError(errPtr);
        return error;
    }

    override bool clearError() const @nogc nothrow
    {
        return false;
    }
}
