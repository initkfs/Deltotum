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

    //The audio data MUST be in the exact same format as the audio device.
    this(ubyte[] buffer)
    {
        Mix_Chunk* newPtr = Mix_QuickLoad_RAW(cast(Uint8*) buffer, cast(Uint32) buffer.length);
        if (!newPtr)
        {
            throw new Exception(getErrorRes("Error loading mixer chunk from buffer").toString);
        }
        this.ptr = newPtr;
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

    ComResult play(int loops = -1, int ticks = -1)
    {
        assert(ptr);

        int channel = -1;
        int isPlay = Mix_PlayChannelTimed(channel, ptr, loops, ticks);
        if (isPlay == -1)
        {
            return getErrorRes("Error playing mix chunk");
        }
        return ComResult.success;
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
