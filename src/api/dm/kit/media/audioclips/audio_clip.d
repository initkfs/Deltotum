module api.dm.kit.media.audioclips.audio_clip;

import api.dm.back.sdl3.mixer.sdl_mixer_lib : SdlMixerLib;

import api.dm.back.sdl3.externs.csdl3;

class AudioClip
{

    bool isEnabled;

    private
    {
        SdlMixerLib audioLib;
    }

    this(SdlMixerLib audioLib)
    {
        this.audioLib = audioLib;
        if (audioLib)
        {
            isEnabled = true;
        }

        // if(const err = audioLib.openAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048)){
        //     throw new Exception(err.toString);
        // }
    }
}
