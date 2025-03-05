module api.dm.back.sdl3.mixer.sdl_mixer_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.audio.com_audio_mixer;
import api.dm.back.sdl3.mixer.sdl_mixer_object : SdlMixerObject;

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

    bool openAudio(SDL_AudioDeviceID id, SDL_AudioSpec* spec) nothrow
    {
        //apt-get install libasound2-dev libpulse-dev
        //https://stackoverflow.com/questions/10465202/initializing-sdl-mixer-gives-error-no-available-audio-device
        return Mix_OpenAudio(id, spec);
    }

    ComResult openAudio(ComAudioDeviceId id, ComAudioSpec spec) nothrow
    {
        SDL_AudioSpec sdlSpec = toSdlSpec(spec);
        if (!openAudio(id, &sdlSpec))
        {
            return getErrorRes("Error open SDL audio");
        }
        return ComResult.success;
    }

    ComResult openAudio(ComAudioSpec spec) nothrow => openAudio(0, spec);

    ComResult openAudio() nothrow
    {
        ComAudioSpec spec;
        return openAudio(spec);
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

    ComResult query(out ComAudioSpec spec) nothrow
    {
        int frequency;
        SDL_AudioFormat format;
        int channels;
        if (!query(&frequency, &format, &channels))
        {
            return getErrorRes("Error getting query audio spec");
        }
        spec = ComAudioSpec(fromSdlFormat(format), channels, frequency);
        return ComResult.success;
    }

    bool query(int* frequency, SDL_AudioFormat* format, int* channels) nothrow
    {
        return Mix_QuerySpec(frequency, format, channels);
    }

    bool isPlaying() nothrow
    {
        return Mix_PlayingMusic();
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
        Mix_CloseAudio();
    }

    void quit() nothrow
    {
        close;

        Mix_Quit();
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
        return SDL_AudioSpec(format, spec.channels, spec.freq);
    }

}
