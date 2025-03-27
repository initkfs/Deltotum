module api.dm.kit.media.multimedia;

import api.core.components.units.simple_unit : SimpleUnit;
import api.dm.com.audio.com_audio_device: ComAudioDevice;
import api.dm.kit.media.mixers.audio_mixer : AudioMixer;

/**
 * Authors: initkfs
 */
class MultiMedia : SimpleUnit
{
    ComAudioDevice audioOut;

    AudioMixer mixer;

    this(AudioMixer mixer, ComAudioDevice audioOut)
    {
        assert(mixer);

        this.mixer = mixer;

        assert(audioOut);
        this.audioOut = audioOut;
    }
}
