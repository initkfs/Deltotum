module api.dm.back.sdl3.mixers.sdl_mixer_music;

import api.dm.com.com_result;

import api.dm.com.com_result : ComResult;
import api.dm.back.sdl3.mixers.sdl_mixer_object : SdlMixerObject;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.com.audio.com_audio_clip : ComAudioClip;

import std.string : toStringz, fromStringz;
import api.dm.back.sdl3.externs.csdl3;

class SdlMixerMusic : SdlObjectWrapper!(Mix_Music), ComAudioClip
{
    protected
    {
        enum msInSec = 1000;
        enum double doubleErr = -1;
    }

    ComResult create(string path) nothrow
    {
        Mix_Music* ptr = Mix_LoadMUS(path.toStringz);
        if (!ptr)
        {
            import std.conv : text;

            return getErrorRes(text("Error loading music ", path));
        }
        return setWithDispose(ptr);
    }

    ComResult getType(out string type) nothrow
    {
        assert(ptr);
        Mix_MusicType sdlType = Mix_GetMusicType(ptr);
        try
        {
            import std.conv : to;

            type = sdlType.to!string;
        }
        catch (Exception e)
        {
            return ComResult.error(e.msg);
        }
        return ComResult.success;
    }

    ComResult getLoopStartTimeMs(out double timeMs) nothrow
    {
        assert(ptr);
        double v = Mix_GetMusicLoopStartTime(ptr);
        if (v == doubleErr)
        {
            return getErrorRes("Error getting loop start time");
        }
        timeMs = v * msInSec;
        return ComResult.success;
    }

    ComResult getLoopEndTimeMs(out double timeMs) nothrow
    {
        assert(ptr);
        double v = Mix_GetMusicLoopEndTime(ptr);
        if (v == doubleErr)
        {
            return getErrorRes("Error getting loop end time");
        }
        timeMs = v * msInSec;
        return ComResult.success;
    }

    ComResult getLoopLengthTimeMs(out double timeMs) nothrow
    {
        assert(ptr);
        double v = Mix_GetMusicLoopLengthTime(ptr);
        if (v == doubleErr)
        {
            return getErrorRes("Error getting loop length time");
        }
        timeMs = v * msInSec;
        return ComResult.success;
    }

    ComResult getDurationTimeMs(out double timeMs) nothrow
    {
        assert(ptr);
        double v = Mix_MusicDuration(ptr);
        if (v == doubleErr)
        {
            return getErrorRes("Error getting music duration");
        }
        timeMs = v * msInSec;
        return ComResult.success;
    }

    ComResult getPosTimeMs(out double timeMs) nothrow
    {
        assert(ptr);
        double v = Mix_GetMusicPosition(ptr);
        if (v == doubleErr)
        {
            return getErrorRes("Error getting music duration");
        }
        timeMs = v * msInSec;
        return ComResult.success;
    }

    ComResult getTitleTag(out string title) nothrow
    {
        assert(ptr);
        const char* titlePtr = Mix_GetMusicTitleTag(ptr);
        title = titlePtr.fromStringz.idup;
        return ComResult.success;
    }

    ComResult getTitle(out string title) nothrow
    {
        assert(ptr);
        const char* titlePtr = Mix_GetMusicTitle(ptr);
        title = titlePtr.fromStringz.idup;
        return ComResult.success;
    }

    ComResult setVolume(double value) nothrow
    {
        auto sdlVolume = cast(typeof(MIX_MAX_VOLUME))(value * MIX_MAX_VOLUME);
        Mix_VolumeMusic(sdlVolume);
        return ComResult.success;
    }

    ComResult getVolume(out double value) nothrow
    {
        assert(ptr);
        value = Mix_GetMusicVolume(ptr);
        return ComResult.success;
    }

    ComResult play() nothrow => play(0);

    //-1 repeat
    ComResult play(int loops) nothrow
    {
        assert(ptr);
        if (!Mix_PlayMusic(ptr, loops))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult stop() nothrow
    {
        Mix_HaltMusic();
        return ComResult.success;
    }

    ComResult pause() nothrow
    {
        Mix_PauseMusic();
        return ComResult.success;
    }

    ComResult resume() nothrow
    {
        Mix_ResumeMusic();
        return ComResult.success;
    }

    ComResult setPos(double posMs) nothrow
    {
        double posSec = posMs / 1000.0;
        if (!Mix_SetMusicPosition(posSec))
        {
            return getErrorRes("Error setting music position");
        }
        return ComResult.success;
    }

    bool isPlaying() nothrow
    {
        return Mix_PlayingMusic();
    }

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            Mix_FreeMusic(ptr);
            return true;
        }

        return false;
    }
}
