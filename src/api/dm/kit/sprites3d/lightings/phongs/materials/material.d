module api.dm.kit.sprites3d.lightings.phongs.materials.material;

import api.math.geom2.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

struct PhongData
{
    align(16):
    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
    Vec3f color;
    align(4):
    float shininess = 32;
}

static assert(PhongData.sizeof % 16 == 0);

struct LightData {
    align(16):
    Vec3f position;
    Vec3f direction;
    Vec3f lightDirection;
    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
    align(4):
    float constant = 0;
    float linear = 0;
    float quadratic = 0;
    float cutoff = 0;
    float outerCutoff = 0;
    uint type;
}

static assert(LightData.sizeof % 16 == 0);

