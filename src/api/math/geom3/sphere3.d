module api.math.geom3.sphere3;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

alias Sphere3 = Sphere3f;

struct Sphere3f
{
    Vec3f center;
    float radius = 0;
}
