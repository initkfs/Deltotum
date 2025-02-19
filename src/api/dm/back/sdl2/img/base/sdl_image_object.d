module api.dm.back.sdl2.img.base.sdl_image_object;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.back.sdl2.base.sdl_object : SdlObject;
import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlImageObject : SdlObject
{
    override string getError() const nothrow
    {
        const char* errPtr = IMG_GetError();
        const error = ptrToStr(errPtr);
        return error;
    }

    override bool clearError() const nothrow
    {
        return false;
    }
}
