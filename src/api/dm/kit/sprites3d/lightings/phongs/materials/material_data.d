module api.dm.kit.sprites3d.lightings.phongs.materials.material_data;

import api.math.geom3.vec3 : Vec3f;
import api.math.geom4.vec4 : Vec4f;
import api.dm.kit.graphics.colors.rgba : RGBAf;

/**
 * Authors: initkfs
 */

/** 
 * Chalk (Dielectric, Matte):
   Albedo: White/Beige.
   Specular RGB: Almost black (e.g., 0.02, 0.02, 0.02). 
   Specular A (Gloss): Low value (0.1).

   Plastic (Dielectric, Glossy):
   Albedo: Any color.
   Specular RGB: Gray/White (e.g., 0.05, 0.05, 0.05).
   Specular A (Gloss): High value (0.8).
   
   Gold (Metal):
   Albedo: Black (metals physically have no diffuse).
   Specular RGB: Yellow/Gold (1.0, 0.8, 0.2).
   Specular A (Gloss): High value (0.9)
 */

struct Material
{
    float[4] albedo;
    float[4] ambient;
    float[4] reserve0;
    float[4] specular; //A - gloss, 0 to 1
align(4):
    float shininess = 32;
    float intensity = 0;
    float gloss = 0.5;
    float reserve2;
}

struct Light
{
    Vec3f position;
    uint lightType;
    Vec3f direction;
    float linearCoeff = 0;
    Vec3f lightDirection;
    float radius = 0;
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
immutable Vec3f[size_t] coeffMap = [
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

import std.array : array;
import std.algorithm.sorting : sort;

immutable size_t[] coeffMapKeys = coeffMap.keys.sort.array;

Vec3f interpFromDist(float distance)
{
    //float distance = (objectPosition - position).length();
    //TODO binary search
    assert(coeffMapKeys.length != 0);
    const lastIdx = coeffMapKeys.length - 1;

    size_t lowerIdx, upperIdx;
    foreach (i; 0 .. lastIdx)
    {
        const nextIdx = i + 1;
        if (distance >= coeffMapKeys[i] && distance <= coeffMapKeys[nextIdx])
        {
            lowerIdx = i;
            upperIdx = nextIdx;
            break;
        }
    }

    if (distance < coeffMapKeys[0])
    {
        return coeffMap[coeffMapKeys[0]];
    }
    if (distance > coeffMapKeys[lastIdx])
    {
        return coeffMap[coeffMapKeys[lastIdx]];
    }

    float d1 = coeffMapKeys[lowerIdx];
    float d2 = coeffMapKeys[upperIdx];
    float t = (distance - d1) / (d2 - d1); //[0, 1]

    Vec3f c1 = coeffMap[coeffMapKeys[lowerIdx]];
    Vec3f c2 = coeffMap[coeffMapKeys[upperIdx]];

    return Vec3f(
        c1.x + t * (c2.x - c1.x),
        c1.y + t * (c2.y - c1.y),
        c1.z + t * (c2.z - c1.z)
    );
}

unittest
{
    import std.math.operations : isClose;

    auto res1 = interpFromDist(10);
    assert(isClose(res1.staticArr[], [1, 0.52, 1.12], 0.01));
}

struct MatPreset
{
    string name;
    RGBAf albedo;
    RGBAf specular;
    float gloss;
}

MatPreset chalkPlaster = MatPreset("Chalk / Plaster", RGBAf(0.9, 0.9, 0.9, 1.0), RGBAf(0.02, 0.02, 0.02, 1.0), 0.075); //gloss 0.05-0.1
MatPreset woodMatte = MatPreset("Wood (Matte)", RGBAf(0.5, 0.3, 0.1, 1.0), RGBAf(0.03, 0.03, 0.03, 1.0), 0.25); // 0.2-0.3 avg
MatPreset leather = MatPreset("Leather", RGBAf(0.6, 0.4, 0.3, 1.0), RGBAf(0.04, 0.04, 0.04, 1.0), 0.35); // 0.3-0.4 avg
MatPreset plasticSmooth = MatPreset("Plastic (Smooth)", RGBAf(0.1, 0.1, 0.1, 1.0), RGBAf(0.05, 0.05, 0.05, 1.0), 0.75); // 0.7-0.8 avg
MatPreset glassIce = MatPreset("Glass / Ice", RGBAf(0.0, 0.0, 0.0, 1.0), RGBAf(0.04, 0.04, 0.04, 1.0), 0.95);
MatPreset steelIron = MatPreset("Steel / Iron", RGBAf(0.05, 0.05, 0.05, 1.0), RGBAf(0.5, 0.5, 0.5, 1.0), 0.70); // 0.6-0.8 avg
MatPreset gold = MatPreset("Gold", RGBAf(0.02, 0.02, 0.02, 1.0), RGBAf(1.0, 0.8, 0.3, 1.0), 0.90);
MatPreset copper = MatPreset("Copper", RGBAf(0.02, 0.02, 0.02, 1.0), RGBAf(0.9, 0.5, 0.4, 1.0), 0.70);
