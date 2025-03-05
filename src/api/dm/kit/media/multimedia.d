module api.dm.kit.media.multimedia;

import api.core.components.units.simple_unit : SimpleUnit;
import api.dm.kit.media.audioclips.audio_clip : AudioClip;

/**
 * Authors: initkfs
 */
class MultiMedia : SimpleUnit
{

    AudioClip audioclip;

    this(AudioClip clip)
    {
        assert(clip);

        this.audioclip = clip;
    }
}
