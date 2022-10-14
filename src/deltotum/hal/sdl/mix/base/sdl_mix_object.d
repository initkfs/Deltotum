module deltotum.hal.sdl.mix.base.sdl_mix_object;

import deltotum.hal.sdl.base.sdl_object : SdlObject;
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
        immutable error = ptrToError(errPtr);
        return error;
    }

    override bool clearError() const @nogc nothrow
    {
        return false;
    }
}
