module deltotum.hal.sdl.mix.base.sdl_mix_object;

import std.string: fromStringz, toStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlMixObject
{

    string getError() const nothrow
    {
        //TODO remove duplicate with sdl_object
        const char* errPtr = Mix_GetError();
        if (errPtr is null)
        {
            return null;
        }
        string err = errPtr.fromStringz.idup;
        return err.length > 0 ? err : null;
    }

}
