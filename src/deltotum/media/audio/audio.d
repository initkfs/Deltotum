module deltotum.media.audio.audio;

import deltotum.sdl.mix.sdl_mix_lib : SdlMixLib;

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

        if(const err = audioLib.openAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048)){
            throw new Exception(err.toString);
        }
    }

    void destroy()
    {
        audioLib.closeAudio;
    }

}
