module deltotum.hal.sdl.base.sdl_object;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlObject
{
    string getError() const nothrow
    {
        const char* errorPtr = SDL_GetError();
        immutable err = ptrToError(errorPtr);
        return err;
    }

    protected string ptrToError(scope const(char*) errorPtr) const nothrow
    {
        if (!errorPtr)
        {
            return null;
        }
        immutable string error = errorPtr.fromStringz.idup;
        return error.length > 0 ? error : null;
    }

    bool clearError() const @nogc nothrow
    {
        SDL_ClearError();
        return true;
    }

    bool toBool(SDL_bool value) const @nogc nothrow @safe
    {
        final switch (value)
        {
        case SDL_TRUE:
            return true;
        case SDL_FALSE:
            return false;
        }
    }

    SDL_bool fromBool(bool value) const @nogc nothrow @safe
    {
        return value ? SDL_bool.SDL_TRUE : SDL_bool.SDL_FALSE;
    }

    string getSdlVersionInfo() const nothrow
    {
        import std.conv : text;

        SDL_version ver;
        SDL_GetVersion(&ver);
        //format is not nothrow
        return text(ver.major, ".", ver.minor, ".", ver.patch);
    }

    string getHint(string name) const nothrow
    {
        const(char)* hintPtr = SDL_GetHint(name.toStringz);
        if (hintPtr is null)
        {
            return null;
        }
        immutable hintValue = hintPtr.fromStringz.idup;
        return hintValue;
    }

    void clearHints() const @nogc nothrow
    {
        SDL_ClearHints();
    }

    bool setHint(string name, string value) const nothrow
    {
        //TODO string loss due to garbage collector?
        SDL_bool isSet = SDL_SetHint(name.toStringz,
            value.toStringz);
        return toBool(isSet);
    }
}
