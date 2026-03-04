module api.dm.kit.media.audio.mixers.mix_sound;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

alias SoundHandle = size_t;

struct MixSound
{
    float[] samples;

    size_t positionFrame;
    float volume = 1; //[0..1]
    float pan = 0; // [-1..1]
    Vec3f geomPosition;
    extern(C) void function(void*) freeFunPtr;
    bool loop;
    bool playing;
    string name;

    bool free()
    {
        if (!freeFunPtr || samples.length == 0)
        {
            return false;
        }

        freeFunPtr(samples.ptr);
        samples = null;
        return true;
    }
}
