module deltotum.audio.audio;

import deltotum.hal.sdl.mix.sdl_mix_lib : SdlMixLib;

import bindbc.sdl;

class Audio
{

    private
    {
        SdlMixLib audioLib;
    }

    this(SdlMixLib audioLib)
    {
        this.audioLib = audioLib;

        audioLib.openAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048);
    }

    void destroy()
    {
        audioLib.closeAudio;
    }

}
