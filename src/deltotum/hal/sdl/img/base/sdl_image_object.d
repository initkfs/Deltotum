module deltotum.hal.sdl.img.base.sdl_image_object;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImageObject
{

    string getError() const nothrow
    {
        //TODO remove duplicate with sdl_object
        const char* errPtr = IMG_GetError();
        if (errPtr is null)
        {
            return null;
        }
        string err = errPtr.fromStringz.idup;
        return err.length > 0 ? err : null;
    }
}
