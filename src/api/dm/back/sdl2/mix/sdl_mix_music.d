module api.dm.back.sdl2.mix.sdl_mix_music;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl2.mix.base.sdl_mix_object : SdlMixObject;
import api.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;

import std.string : toStringz, fromStringz;
import api.dm.back.sdl3.externs.csdl3;

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

    ComResult load() nothrow
    {
        isLoad = false;
        if (path.length == 0)
        {
            return ComResult.error("Sound path is empty");
        }

        auto musPtr = Mix_LoadMUS(this.path.toStringz);
        if (!musPtr)
        {
            return ComResult.error("Cannot load sound file from " ~ path);
        }

        ptr = musPtr;
        isLoad = true;

        return ComResult.success;
    }

    ComResult play(int loops = -1) nothrow
    {
        if (!isLoad)
        {
            return ComResult.error("Sound not loaded");
        }

        if (!Mix_PlayMusic(ptr, loops))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult stop() nothrow
    {
        if (!isLoad)
        {
            return ComResult.error("Sound not loaded");
        }

        Mix_HaltMusic();
        return ComResult.success;
    }

    bool disposePtr()
    {
        if (ptr)
        {
            Mix_FreeMusic(ptr);
            return true;
        }

        return false;
    }
}
