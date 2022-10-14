module deltotum.hal.sdl.mix.sdl_mix_music;

import deltotum.hal.result.hal_result: HalResult;
import deltotum.hal.sdl.mix.base.sdl_mix_object : SdlMixObject;

import std.string: toStringz, fromStringz;
import bindbc.sdl;

class SdlMixMusic : SdlMixObject
{
    private
    {
        Mix_Music* ptr;
        string path;
    }

    this(string path)
    {
        this.path = path;
        ptr = Mix_LoadMUS(this.path.toStringz);
        if (!ptr)
        {
            string error = "Cannot load music from " ~ path ~ ".";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    HalResult play(int loops = -1) nothrow
    {
        immutable int zeroOrErrorCode = Mix_PlayMusic(ptr, loops);
        return HalResult(zeroOrErrorCode);
    }

    HalResult stop() nothrow
    {
        immutable int alwaysZero = Mix_HaltMusic();
        return HalResult(alwaysZero);
    }

    void destroy()
    {
        Mix_FreeMusic(ptr);
    }
}
