module deltotum.sys.sdl.base.sdl_type_converter;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.objects.com_object : ComObject;
import deltotum.com.graphics.com_blend_mode : ComBlendMode;
import deltotum.com.platforms.types.com_type_convertor : ComTypeConvertor;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlTypeConverter : ComTypeConvertor
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

    SDL_BlendMode toNativeBlendMode(ComBlendMode mode) const @nogc nothrow @safe
    {
        SDL_BlendMode newMode;
        final switch (mode) with (ComBlendMode)
        {
            case blend:
                newMode = SDL_BLENDMODE_BLEND;
                break;
            case add:
                newMode = SDL_BLENDMODE_ADD;
                break;
            case mod:
                newMode = SDL_BLENDMODE_MOD;
                break;
            case mul:
                newMode = SDL_BLENDMODE_MUL;
                break;
            case none:
                newMode = SDL_BLENDMODE_NONE;
                break;
        }
        return newMode;
    }

    ComBlendMode fromNativeBlendMode(SDL_BlendMode mode) const @nogc nothrow @safe
    {
        ComBlendMode newMode;
        final switch (mode)
        {
            case SDL_BLENDMODE_BLEND:
                newMode = ComBlendMode.blend;
                break;
            case SDL_BLENDMODE_ADD:
                newMode = ComBlendMode.add;
                break;
            case SDL_BLENDMODE_MOD:
                newMode = ComBlendMode.mod;
                break;
            case SDL_BLENDMODE_MUL:
                newMode = ComBlendMode.mul;
                break;
            case SDL_BLENDMODE_NONE:
                newMode = ComBlendMode.none;
                break;
        }
        return newMode;
    }
}
