module api.dm.kit.sprites3d.lightings.phongs.materials.material;

import api.math.geom3.vec3 : Vec3f;
import api.math.geom4.vec4 : Vec4f;

/**
 * Authors: initkfs
 */

struct Material
{
    float[4] albedo;
    float[4] ambient;
    float[4] diffuse;
    float[4] specular;
align(4):
    float shininess = 32;
    float intensity = 0;
}

struct Light
{
    Vec3f position;
    uint lightType;
    Vec3f direction;
    float linearCoeff = 0;
    Vec3f lightDirection;
    float constantCoeff = 0;
    Vec3f ambient;
    float quadraticCoeff = 0;
    Vec3f diffuse;
    float cutoff = 0;
    Vec3f specular;
    float outerCutoff = 0;
}

static assert(Light.sizeof == 96);
