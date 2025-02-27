module api.dm.back.sdl3.base.sdl_object;

import api.math.geom2.rect2;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.objects.com_object : ComObject;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;

import api.math.geom2.rect2 : Rect2d;

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlObject : ComObject
{
    ComResult getErrorRes(int code = -1) const nothrow
    {
        return ComResult.error(code, null, getError);
    }

    ComResult getErrorRes(string message) const nothrow
    {
        return ComResult.error(-1, message, getError);
    }

    ComResult getErrorRes(int code, string message) const nothrow
    {
        return ComResult.error(code, message, getError);
    }

    string getError() const nothrow
    {
        const char* errorPtr = SDL_GetError();
        const err = ptrToStr(errorPtr);
        return err;
    }

    protected string ptrToStr(const char* errorPtr) const nothrow
    {
        if (!errorPtr)
        {
            return "";
        }
        const error = errorPtr.fromStringz.idup;
        return error;
    }

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

    SDL_Rect toSdlRect(Rect2d rect) pure nothrow
    {
        return SDL_Rect(cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect
                .height);
    }

    Rect2d fromSdlRect(SDL_Rect rect) pure nothrow
    {
        return Rect2d(rect.x, rect.y, rect.w, rect.h);
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

    protected void freeSdlPtr(void* ptr) nothrow
    {
        SDL_free(ptr);
    }

    bool clearError() const nothrow
    {
        SDL_ClearError();
        return true;
    }
}
