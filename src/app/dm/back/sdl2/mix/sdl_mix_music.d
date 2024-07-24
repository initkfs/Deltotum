module app.dm.back.sdl2.mix.sdl_mix_music;

// dfmt off
version(SdlBackend):
// dfmt on

import app.dm.com.platforms.results.com_result : ComResult;
import app.dm.back.sdl2.mix.base.sdl_mix_object : SdlMixObject;
import app.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;

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
        const int zeroOrErrorCode = Mix_PlayMusic(ptr, loops);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult stop() nothrow
    {
        if (!isLoad)
        {
            return ComResult.error("Sound not loaded");
        }

        const int alwaysZero = Mix_HaltMusic();
        if (alwaysZero != 0)
        {
            return getErrorRes(alwaysZero);
        }

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
