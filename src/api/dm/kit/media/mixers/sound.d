module api.dm.kit.media.mixers.sound;

import api.math.geom3.vec3: Vec3f;

/**
 * Authors: initkfs
 */

struct Sound
{
    float[] samples;

    size_t position;
    float volume = 1; //[0..1]
    float pan = 0; // [-1..1]
    bool loop; //
    bool playing; //
    bool active;
    Vec3f geomPosition;
}

alias SoundHandle = size_t;