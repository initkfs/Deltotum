module api.dm.kit.media.multimedia;

import api.core.components.units.simple_unit : SimpleUnit;
import api.dm.kit.media.mixers.audio_mixer : AudioMixer;

/**
 * Authors: initkfs
 */
class MultiMedia : SimpleUnit
{

    AudioMixer mixer;

    this(AudioMixer mixer)
    {
        assert(mixer);

        this.mixer = mixer;
    }
}
