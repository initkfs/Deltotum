module api.dm.kit.sprites3d.materials.material;

import api.math.geom2.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

struct Material
{
    //specular
    float shininess = 32;
    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
    float[2] _padding;
}

static assert(Material.sizeof % 16 == 0);

struct Light {
    align(16):
    Vec3f position;
    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
}

static assert(Light.sizeof % 16 == 0);

