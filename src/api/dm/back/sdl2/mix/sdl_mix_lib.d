module api.dm.back.sdl2.mix.sdl_mix_lib;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.back.sdl2.mix.base.sdl_mix_object : SdlMixObject;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlMixLib : SdlMixObject
{
    //https://stackoverflow.com/questions/50380940/sdl-mix-loadmus-not-loading-mp3
    //https://stackoverflow.com/questions/55442738/sdl-mixer-2-0-4-mp3-support-not-available-even-though-libmpg123-is-installed
    void initialize(int flags = 0) const
    {
        auto loadResult = loadSDLMixer();
        if (loadResult != sdlMixerSupport)
        {
            string error = "Unable to load SDL mixer.";
            if (loadResult == SDLMixerSupport.noLibrary)
            {
                error ~= " The SDL mixer shared library failed to load.";
            }
            else if (loadResult == SDLMixerSupport.badLibrary)
            {
                error ~= " One or more symbols in SDL mixer failed to load.";
            }

            throw new Exception(error);
        }

        int initResult = Mix_Init(flags);
        if ((initResult & flags) != flags)
        {
            string error = "Unable to initialize SDL mixer library.";
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }
    }

    ComResult openAudio(int frequency, ushort audioFormat, int channels, int chunksize)
    {
        const int zeroOrErrorCode = Mix_OpenAudio(frequency, audioFormat, channels, chunksize);
        if (zeroOrErrorCode)
        {
            import std.format : format;

            immutable errMessage = format(
                "Error opening audio with frequency %s, format %s, channels %s, chunksize %s", frequency, audioFormat, channels, chunksize);
            return getErrorRes(zeroOrErrorCode, errMessage);
        }
        return ComResult.success;
    }

    void closeAudio()
    {
        Mix_CloseAudio();
    }

    void quit() const nothrow
    {
        Mix_Quit();
    }

}
