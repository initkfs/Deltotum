module api.dm.back.sdl2.base.sdl_type_converter;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.objects.com_object : ComObject;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.platforms.types.com_type_convertor : ComTypeConvertor;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlTypeConverter : ComTypeConvertor
{
    bool toBool(sdlbool value) const nothrow @safe
    {
        return value;
    }

    sdlbool fromBool(bool value) const nothrow @safe
    {
        return value;
    }

    SDL_BlendMode toNativeBlendMode(ComBlendMode mode) const nothrow @safe
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

    ComBlendMode fromNativeBlendMode(SDL_BlendMode mode) const nothrow @safe
    {
        ComBlendMode newMode;
        switch (mode)
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
            case SDL_BLENDMODE_NONE, SDL_BLENDMODE_BLEND_PREMULTIPLIED, SDL_BLENDMODE_ADD_PREMULTIPLIED, SDL_BLENDMODE_INVALID:
                newMode = ComBlendMode.none;
                break;
            default:
                break;
        }
        return newMode;
    }
}
