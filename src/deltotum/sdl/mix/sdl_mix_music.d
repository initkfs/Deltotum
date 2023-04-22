module deltotum.sdl.mix.sdl_mix_music;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.results.platform_result : PlatformResult;
import deltotum.sdl.mix.base.sdl_mix_object : SdlMixObject;
import deltotum.com.objects.platform_object_wrapper : PlatformObjectWrapper;

import std.string : toStringz, fromStringz;
import bindbc.sdl;

class SdlMixMusic : SdlMixObject
{
    mixin PlatformObjectWrapper!(Mix_Music);

    protected
    {
        string path;
        bool isLoad;
    }

    this(string path)
    {
        this.path = path;
    }

    bool load()
    {
        isLoad = false;
        if (path.length == 0)
        {
            return isLoad;
        }

        auto musPtr = Mix_LoadMUS(this.path.toStringz);
        if (!musPtr)
        {
            string error = "Cannot load music from " ~ path ~ ".";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
        ptr = musPtr;
        isLoad = true;
        return isLoad;
    }

    PlatformResult play(int loops = -1) nothrow
    {
        if (!isLoad)
        {
            return PlatformResult(-1, "Sound not loaded");
        }
        const int zeroOrErrorCode = Mix_PlayMusic(ptr, loops);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult stop() nothrow
    {
        if (!isLoad)
        {
            return PlatformResult(-1, "Sound not loaded");
        }

        const int alwaysZero = Mix_HaltMusic();
        return PlatformResult(alwaysZero);
    }

    bool destroyPtr()
    {
        if(!ptr){
            return false;
        }
        Mix_FreeMusic(ptr);
        return true;
    }
}
