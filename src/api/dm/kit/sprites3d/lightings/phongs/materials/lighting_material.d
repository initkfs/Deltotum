module api.dm.kit.sprites3d.lightings.phongs.materials.lighting_material;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class LightingMaterial : Sprite3d
{
    TextureGPU diffuseMap;
    TextureGPU specularMap;
    TextureGPU normalMap;

    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
    Vec3f color;
    float shininess = 32;

    bool isBindDiffuseMap = true;
    bool isBindSpecularMap = true;
    bool isBindNormalMap = true;

    protected
    {
        string diffuseMapPath;
        string specularMapPath;
        string normalMapPath;
    }

    this(string diffuseMapPath, string specularMapPath = null, string normalMapPath = null)
    {
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;
        this.normalMapPath = normalMapPath;

        id = "LightMaterial";
    }

    override void create()
    {
        super.create;

        if (!diffuseMap)
        {
            if (diffuseMapPath.length > 0)
            {
                diffuseMap = new TextureGPU;
                build(diffuseMap);
                diffuseMap.create(diffuseMapPath);
                addCreate(diffuseMap);
            }
        }
        else
        {
            addCreate(diffuseMap);
        }

        if (!specularMap)
        {
            if (specularMapPath.length > 0)
            {
                specularMap = new TextureGPU;
                build(specularMap);
                specularMap.create(specularMapPath);
                addCreate(specularMap);
            }
        }
        else
        {
            addCreate(specularMap);
        }

         if (!normalMap)
        {
            if (normalMapPath.length > 0)
            {
                normalMap = new TextureGPU;
                build(normalMap);
                normalMap.create(normalMapPath);
                addCreate(normalMap);
            }
        }
        else
        {
            addCreate(normalMap);
        }
    }
}
