module dm.kit.media.audio.audio;

import dm.backends.sdl2.mix.sdl_mix_lib : SdlMixLib;

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

    void dispose()
    {
        audioLib.closeAudio;
    }

}
