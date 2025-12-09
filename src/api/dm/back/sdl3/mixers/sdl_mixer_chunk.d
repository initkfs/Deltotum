module api.dm.back.sdl3.mixers.sdl_mixer_chunk;

import api.dm.com.com_result;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;

import api.dm.com.com_result : ComResult;
import api.dm.back.sdl3.mixers.sdl_mixer_object : SdlMixerObject;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.objects.com_ptr_manager : ComPtrManager;

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
        enum float floatErr = -1;

        int _lastChannel = -1;
    }

    this()
    {

    }

    this(Mix_Chunk* ptr) pure  nothrow
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

    int allocated()  nothrow @safe
    {
        assert(ptr);
        return ptr.allocated;
    }

    ubyte* buffStart()  nothrow @safe
    {
        assert(ptr);
        return ptr.abuf;
    }

    ubyte* buffEnd()  nothrow
    {
        assert(ptr);
        return buffStart + length;
    }

    uint length()  nothrow @safe
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

    ComResult playFadeIn(int ms = 10, int loops = 0, int ticks = -1) nothrow
    {
        assert(ptr);
        int targetChannel = _lastChannel >= 0 ? _lastChannel : -1;
        int channel = Mix_FadeInChannelTimed(targetChannel, ptr, loops, ms, ticks);
        if (channel == -1)
        {
            return getErrorRes("Error fading chunk");
        }
        _lastChannel = channel;
        return ComResult.success;
    }

    ComResult play(int loops = -1, int ticks = -1)
    {
        assert(ptr);

        int channel = -1;
        _lastChannel = Mix_PlayChannelTimed(channel, ptr, loops, ticks);
        if (_lastChannel == -1)
        {
            return getErrorRes("Error playing mix chunk");
        }
        return ComResult.success;
    }

    ComResult stop()
    {
        if (_lastChannel < 0)
        {
            return ComResult.error("Error stopping shunk, invalid channel");
        }
        Mix_HaltChannel(_lastChannel);
        return ComResult.success;
    }

    int lastChannel() nothrow => _lastChannel;

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
