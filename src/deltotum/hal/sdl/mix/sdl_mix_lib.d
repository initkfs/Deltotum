module deltotum.hal.sdl.mix.sdl_mix_lib;

import deltotum.hal.sdl.mix.base.sdl_mix_object : SdlMixObject;

import bindbc.sdl;

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

     int openAudio(int frequency, ushort format, int channels, int chunksize)
    {
        const int zeroOrErrorCode = Mix_OpenAudio(frequency, format, channels, chunksize);
        return zeroOrErrorCode;
    }

    void closeAudio(){
        Mix_CloseAudio();
    }

    void quit() const @nogc nothrow
    {
        Mix_Quit();
    }

}
