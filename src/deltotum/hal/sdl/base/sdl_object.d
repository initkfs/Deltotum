module deltotum.hal.sdl.base.sdl_object;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

class SdlObject
{
    string getError() const nothrow
    {
        const char* errorPtr = SDL_GetError();
        immutable string error = errorPtr.fromStringz.idup;
        return error.length > 0 ? error : null;
    }

    bool toBool(SDL_bool value) const @nogc nothrow @safe
    {
        if (value == SDL_bool.SDL_TRUE)
        {
            return true;
        }
        //TODO but what happens if there are other values in the SDL_bool type.
        return false;
    }

    SDL_bool fromBool(bool value) const @nogc nothrow @safe
    {
        return value ? SDL_bool.SDL_TRUE : SDL_bool.SDL_FALSE;
    }
}
