module deltotum.platform.sdl.base.sdl_type_converter;

import deltotum.platform.object.platform_object : PlatformObject;
import deltotum.platform.types.platform_type_convertor: PlatformTypeConvertor;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlTypeConverter : PlatformTypeConvertor
{
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
}
