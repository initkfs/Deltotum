module dm.backends.sdl2.mix.sdl_mix_music;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.platforms.results.com_result : ComResult;
import dm.backends.sdl2.mix.base.sdl_mix_object : SdlMixObject;
import dm.com.platforms.objects.com_ptr_manager : ComPtrManager;

import std.string : toStringz, fromStringz;
import bindbc.sdl;

class SdlMixMusic : SdlMixObject
{
    mixin ComPtrManager!(Mix_Music);

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

    ComResult play(int loops = -1) nothrow
    {
        if (!isLoad)
        {
            return ComResult(-1, "Sound not loaded");
        }
        const int zeroOrErrorCode = Mix_PlayMusic(ptr, loops);
        return ComResult(zeroOrErrorCode);
    }

    ComResult stop() nothrow
    {
        if (!isLoad)
        {
            return ComResult(-1, "Sound not loaded");
        }

        const int alwaysZero = Mix_HaltMusic();
        return ComResult(alwaysZero);
    }

    bool disposePtr()
    {
        if(!ptr){
            return false;
        }
        Mix_FreeMusic(ptr);
        return true;
    }
}
