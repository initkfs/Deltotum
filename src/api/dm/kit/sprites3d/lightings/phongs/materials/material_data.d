module api.dm.kit.sprites3d.lightings.phongs.materials.material_data;

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
    float reserve1;
    float reserve2;
}

struct Light
{
    Vec3f position;
    uint lightType;
    Vec3f direction;
    float linearCoeff = 0;
    Vec3f lightDirection;
    float constantCoeff = 0;
    float[3] ambient;
    float quadraticCoeff = 0;
    float[3] diffuse;
    float cutoff = 0;
    float[3] specular;
    float outerCutoff = 0;
}

static assert(Light.sizeof == 96);

import api.math.geom3 : Vec3f;

/*
* https://wiki.ogre3d.org/tiki-index.php?page=-Point+Light+Attenuation
* under Creative Commons Attribution-ShareAlike License https://wiki.ogre3d.org/Creative+Commons+Attribution-ShareAlike+License?copyrightpage=-Point%20Light%20Attenuation
*/
//Range Constant Linear Quadratic
Vec3f[size_t] coeffMap = [
    7: Vec3f(1.0, 0.7, 1.8),
    13: Vec3f(1.0, 0.35, 0.44),
    20: Vec3f(1.0, 0.22, 0.20),
    32: Vec3f(1.0, 0.14, 0.07),
    50: Vec3f(1.0, 0.09, 0.032),
    65: Vec3f(1.0, 0.07, 0.017),
    100: Vec3f(1.0, 0.045, 0.0075),
    160: Vec3f(1.0, 0.027, 0.0028),
    200: Vec3f(1.0, 0.022, 0.0019),
    325: Vec3f(1.0, 0.014, 0.0007),
    600: Vec3f(1.0, 0.007, 0.0002),
    3250: Vec3f(1.0, 0.0014, 0.000007),
];
