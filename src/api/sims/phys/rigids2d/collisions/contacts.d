module api.sims.phys.rigids2d.collisions.contacts;

/**
 * Authors: initkfs
 */
import api.math.geom2.vec2: Vec2f;

struct Contact2d
{
    Vec2f normal;
    float penetration = 0;
    Vec2f pos;
}