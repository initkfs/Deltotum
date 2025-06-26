module api.dm.back.sdl3.sounds.sdl_audio_types;

import api.dm.com.com_result;

import api.dm.com.com_result : ComResult;
import api.dm.com.audio.com_audio_device;
import api.dm.back.sdl3.base.sdl_object : SdlObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
ComAudioFormat fromSdlFormat(SDL_AudioFormat format) pure nothrow
{
    ComAudioFormat comFormat = ComAudioFormat.none;
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
            break;
    }
    return comFormat;
}

SDL_AudioFormat toSdlFormat(ComAudioFormat format) pure nothrow
{
    SDL_AudioFormat sdlFormat = SDL_AUDIO_UNKNOWN;
    final switch (format)
    {
        case ComAudioFormat.s16:
            sdlFormat = SDL_AUDIO_S16;
            break;
        case ComAudioFormat.s32:
            sdlFormat = SDL_AUDIO_S32;
            break;
        case ComAudioFormat.f32:
            sdlFormat = SDL_AUDIO_F32;
            break;
        case ComAudioFormat.none:
            break;
    }
    return sdlFormat;
}

SDL_AudioSpec toSdlSpec(ComAudioSpec spec) pure nothrow
{
    return SDL_AudioSpec(toSdlFormat(spec.format), cast(int) spec.channels, spec.freqHz);
}

ComAudioSpec fromSdlSpec(SDL_AudioSpec spec) pure nothrow
{
    import std.conv : to;

    //TODO channels == -1, signed -> unsigned?
    return ComAudioSpec(fromSdlFormat(spec.format), spec.freq, cast(size_t) spec.channels);
}
