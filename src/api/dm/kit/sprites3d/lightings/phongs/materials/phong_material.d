module api.dm.kit.sprites3d.lightings.phongs.materials.phong_material;

import api.dm.kit.sprites3d.lightings.lighting_material : LightingMaterial;
import api.math.geom2.vec3 : Vec3f;

/**
 * Authors: initkfs
 */
class PhongMaterial : LightingMaterial
{
    this(string diffuseMapPath, string specularMapPath)
    {
        super(diffuseMapPath, specularMapPath);
    }
}
