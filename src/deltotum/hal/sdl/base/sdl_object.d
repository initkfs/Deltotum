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

    void clearError() const @nogc nothrow
    {
        //Move from SdlObject to prevent accidental call and error loss
        SDL_ClearError();
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

    string getSdlVersionInfo() const
    {
        import std.format : format;

        SDL_version ver;
        SDL_GetVersion(&ver);
        return format("%s.%s.%s", ver.major, ver.minor, ver.patch);
    }

    string getHint(string name) const nothrow
    {
        const(char)* hintPtr = SDL_GetHint(name.toStringz);
        string hintValue = hintPtr.fromStringz.idup;
        return hintValue;
    }

    void clearHints() const @nogc nothrow
    {
        SDL_ClearHints();
    }

    bool setHint(string name, string value)
    {
        //TODO string loss due to garbage collector?
        SDL_bool isSet = SDL_SetHint(name.toStringz,
            value.toStringz);
        if (const err = getError)
        {
            throw new Exception(err);
        }
        return toBool(isSet);
    }
}
