module api.dm.back.sdl3.mixer.sdl_mixer_chunk;

import api.dm.com.platforms.results.com_result;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl3.mixer.sdl_mixer_object : SdlMixerObject;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.platforms.objects.com_ptr_manager : ComPtrManager;

import std.string : toStringz, fromStringz;
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlMixerChunk : SdlObjectWrapper!Mix_Chunk, ComAudioChunk
{
    protected
    {
        enum msInSec = 1000;
        enum double doubleErr = -1;
    }

    this()
    {

    }

    this(Mix_Chunk* ptr) pure @nogc nothrow
    {
        assert(ptr);
        this.ptr = ptr;
    }

    ubyte[] buffer() nothrow
    {
        assert(length > 0);
        return buffStart[0 .. length];
    }

    int allocated() @nogc nothrow @safe
    {
        assert(ptr);
        return ptr.allocated;
    }

    ubyte* buffStart() @nogc nothrow @safe
    {
        assert(ptr);
        return ptr.abuf;
    }

    ubyte* buffEnd() @nogc nothrow
    {
        assert(ptr);
        return buffStart + length;
    }

    uint length() @nogc nothrow @safe
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

    override bool disposePtr()
    {
        if (ptr)
        {
            Mix_FreeChunk(ptr);
            return true;
        }

        return false;
    }
}
