module deltotum.platforms.sdl.mix.sdl_mix_music;

import deltotum.platforms.result.platform_result: PlatformResult;
import deltotum.platforms.sdl.mix.base.sdl_mix_object : SdlMixObject;

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

    PlatformResult play(int loops = -1) nothrow
    {
        immutable int zeroOrErrorCode = Mix_PlayMusic(ptr, loops);
        return PlatformResult(zeroOrErrorCode);
    }

    PlatformResult stop() nothrow
    {
        immutable int alwaysZero = Mix_HaltMusic();
        return PlatformResult(alwaysZero);
    }

    void destroy()
    {
        Mix_FreeMusic(ptr);
    }
}
