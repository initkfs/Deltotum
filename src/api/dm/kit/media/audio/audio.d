module api.dm.kit.media.audio.audio;

import api.dm.back.sdl2.mix.sdl_mix_lib : SdlMixLib;

import api.dm.back.sdl3.externs.csdl3;

class Audio
{

    private
    {
        SdlMixLib audioLib;
    }

    this(SdlMixLib audioLib)
    {
        this.audioLib = audioLib;

        // if(const err = audioLib.openAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048)){
        //     throw new Exception(err.toString);
        // }
    }

    void dispose()
    {
        audioLib.closeAudio;
    }

}
