module dm.back.sdl2.mix.base.sdl_mix_object;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.back.sdl2.base.sdl_object : SdlObject;
import std.string : fromStringz, toStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlMixObject : SdlObject
{

    override string getError() const nothrow
    {
        const char* errPtr = Mix_GetError();
        const error = ptrToStr(errPtr);
        return error;
    }

    override bool clearError() const nothrow
    {
        return false;
    }
}
