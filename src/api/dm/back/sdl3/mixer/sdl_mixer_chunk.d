module api.dm.back.sdl3.mixer.sdl_mixer_chunk;

import api.dm.com.platforms.results.com_result;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.mixer.sdl_mixer_object : SdlMixerObject;
import api.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;

import std.string : toStringz, fromStringz;
import api.dm.back.sdl3.externs.csdl3;

class SdlMixerMusic : SdlMixerObject
{
    mixin ComPtrManager!(Mix_Chunk);

    protected
    {
        enum msInSec = 1000;
        enum double doubleErr = -1;
    }

    int allocated()
    {
        assert(ptr);
        return ptr.allocated;
    }

    ubyte* buffStart()
    {
        assert(ptr);
        return ptr.abuf;
    }

    ubyte* buffEnd()
    {
        assert(ptr);
        return buffStart + length;
    }

    uint length()
    {
        assert(ptr);
        return ptr.alen;
    }

    ubyte volume()
    {
        assert(ptr);
        return ptr.volume;
    }

    int volume(int value)
    {
        assert(ptr);
        return Mix_VolumeChunk(ptr, value);
    }

    bool disposePtr()
    {
        if (ptr)
        {
            Mix_FreeChunk(ptr);
            return true;
        }

        return false;
    }
}
