module deltotum.hal.sdl.img.base.sdl_image_object;

import deltotum.hal.sdl.base.sdl_object : SdlObject;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImageObject : SdlObject
{
    override string getError() const nothrow
    {
        const char* errPtr = IMG_GetError();
        immutable error = ptrToError(errPtr);
        return error;
    }

    override bool clearError() const @nogc nothrow
    {
        return false;
    }
}
