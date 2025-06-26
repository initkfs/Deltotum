module api.dm.back.sdl3.mixers.sdl_mixer_lib;

import api.dm.com.com_result : ComResult;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.com.audio.com_audio_mixer;
import api.dm.com.audio.com_audio_device;
import api.dm.back.sdl3.mixers.sdl_mixer_object : SdlMixerObject;
import api.dm.back.sdl3.mixers.sdl_mixer_music : SdlMixerMusic;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlMixerLib : SdlMixerObject, ComAudioMixer
{

    ComResult initialize(int flags = 0) const
    {
        int initResult = Mix_Init(flags);
        if ((initResult & flags) != flags)
        {
            return getErrorRes("Unable to initialize SDL mixer library.");
        }
        return ComResult.success;
    }

    override string linkedVersionString() nothrow => stringFromVersion(Mix_Version());

    bool open(SDL_AudioDeviceID id, SDL_AudioSpec* spec) nothrow
    {
        //apt-get install libasound2-dev libpulse-dev
        //https://stackoverflow.com/questions/10465202/initializing-sdl-mixer-gives-error-no-available-audio-device
        //https://discourse.libsdl.org/t/couldnt-open-audio-device-no-available-audio-device/18499/13
        return Mix_OpenAudio(id, spec);
    }

    ComResult open(ComAudioDeviceId id, ComAudioSpec spec) nothrow
    {
        SDL_AudioSpec sdlSpec = toSdlSpec(spec);
        if (!open(id, &sdlSpec))
        {
            return getErrorRes("Error open SDL mixer audio");
        }
        return ComResult.success;
    }

    ComResult allocChannels(size_t count) nothrow
    {
        if (count == 0)
        {
            return ComResult.error("Channels must not be 0");
        }

        auto res = Mix_AllocateChannels(cast(int) count);
        if (res != count)
        {
            return getErrorRes("Error channels allocating");
        }
        return ComResult.success;
    }

    ComResult setPostCallback(MixerCallback callback, void* userdata) nothrow
    {
        Mix_SetPostMix(callback, userdata);
        return ComResult.success;
    }

    ComResult setChannelCallback(MixerChannelFinishedCallback callback) nothrow
    {
        Mix_ChannelFinished(callback);
        return ComResult.success;
    }

    ComResult chunkDecoders(out string decoders) nothrow
    {
        import std.string : fromStringz;

        if (const err = onChunkDecoder((ptr) {
                decoders ~= ((ptr.fromStringz.idup) ~ " ");
                return true;
            }))
        {
            return err;
        }
        return ComResult.success;
    }

    ComResult onChunkDecoder(scope bool delegate(const char*) nothrow onChunkIsContinue) nothrow
    {
        auto decoders = Mix_GetNumChunkDecoders();
        foreach (i; 0 .. decoders)
        {
            const char* decoderName = Mix_GetChunkDecoder(i);
            if (decoderName)
            {
                if (!onChunkIsContinue(decoderName))
                {
                    break;
                }
            }
        }
        return ComResult.success;
    }

    ComResult getTracks(out int tracksCount) nothrow
    {
        tracksCount = Mix_AllocateChannels(-1);
        return ComResult.success;
    }

    ComResult setTracks(int tracksCount) nothrow
    {
        const int newChannels = Mix_AllocateChannels(tracksCount);
        if (newChannels != tracksCount)
        {
            return getErrorRes("Error setting channelds count");
        }
        return ComResult.success;
    }

    ComResult setOnTrackFinished(TrackFinishedCallback callback) nothrow
    {
        Mix_ChannelFinished(callback);
        return ComResult.success;
    }

    ComResult setMusicPosition(double positionMs) nothrow
    {
        const positionSec = positionMs * 1000;
        if (!Mix_SetMusicPosition(positionSec))
        {
            return getErrorRes("Error setting SDL music position");
        }
        return ComResult.success;
    }

    void musicVolume(int newValue) nothrow
    {
        import Math = api.math;

        int value = Math.clamp(newValue, 0, MIX_MAX_VOLUME);
        Mix_VolumeMusic(value);
    }

    int musicVolume() nothrow
    {
        return Mix_VolumeMusic(-1);
    }

    bool fadeOut(int channel, int ms) nothrow
    {
        auto chans = Mix_FadeOutChannel(channel, ms);
        return chans == 1;
    }

    ComResult query(out ComAudioSpec spec) nothrow
    {
        int frequency;
        SDL_AudioFormat format;
        int channels;
        if (!query(&frequency, &format, &channels))
        {
            return getErrorRes("Error getting query audio spec");
        }
        spec = ComAudioSpec(fromSdlFormat(format), frequency, channels);
        return ComResult.success;
    }

    bool query(int* frequency, SDL_AudioFormat* format, int* channels) nothrow
    {
        return Mix_QuerySpec(frequency, format, channels);
    }

    bool isPlaying(int channel) nothrow
    {
        if (channel < 0)
        {
            return false;
        }
        auto chanNum = Mix_Playing(channel);
        return chanNum != 0;
    }

    bool isPlaying() nothrow
    {
        return Mix_PlayingMusic();
    }

    void stopChannel(int chan) nothrow
    {
        Mix_HaltChannel(chan);
    }

    void stop() nothrow
    {
        Mix_HaltMusic();
    }

    void pause() nothrow
    {
        Mix_PauseMusic();
    }

    void resume() nothrow
    {
        Mix_ResumeMusic();
    }

    void close() nothrow
    {
        //SDL_PauseAudio(1);
        Mix_CloseAudio();
    }

    void quit() nothrow
    {
        close;

        Mix_Quit();
    }

    ComResult newHeapMusic(string path, out ComAudioClip mus) nothrow
    {
        auto newMus = new SdlMixerMusic;
        if (const err = newMus.create(path))
        {
            newMus.dispose;
            return err;
        }
        mus = newMus;
        return ComResult.success;
    }

    SDL_AudioFormat toSdlFormat(ComAudioFormat comFormat) nothrow
    {
        SDL_AudioFormat format;
        final switch (comFormat) with (ComAudioFormat)
        {
            case none, s16:
                format = SDL_AUDIO_S16;
                break;
            case s32:
                format = SDL_AUDIO_S32;
                break;
            case f32:
                format = SDL_AUDIO_F32;
                break;
        }
        return format;
    }

    ComResult newHeapWav(string path, out ComAudioChunk buffer) nothrow
    {
        import std.string : toStringz;

        Mix_Chunk* chunkPtr = Mix_LoadWAV(path.toStringz);
        if (!chunkPtr)
        {
            return getErrorRes("Error loading WAV file from path");
        }
        import api.dm.back.sdl3.mixers.sdl_mixer_chunk : SdlMixerChunk;

        buffer = new SdlMixerChunk(chunkPtr);
        return ComResult.success;
    }

    ComAudioFormat fromSdlFormat(SDL_AudioFormat format) nothrow
    {
        ComAudioFormat comFormat;
        switch (format)
        {
            case SDL_AUDIO_S16:
                comFormat = ComAudioFormat.s16;
                break;
            case SDL_AUDIO_S32:
                comFormat = ComAudioFormat.s32;
                break;
            case SDL_AUDIO_F32:
                comFormat = ComAudioFormat.f32;
                break;
            default:
                comFormat = ComAudioFormat.none;
                break;
        }
        return comFormat;
    }

    SDL_AudioSpec toSdlSpec(ComAudioSpec spec) nothrow
    {
        SDL_AudioFormat format = toSdlFormat(spec.format);
        return SDL_AudioSpec(format, cast(int) spec.channels, spec.freqHz);
    }

}
