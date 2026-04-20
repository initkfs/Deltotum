module api.dm.kit.sprites3d.lightings.phongs.materials.lighting_material;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;

/**
 * Authors: initkfs
 */

class LightingMaterial : Sprite3d
{
    TextureGPU diffuseMap;
    TextureGPU specularMap;
    TextureGPU normalMap;
    TextureGPU dispMap;

    RGBA ambient = RGBA.white;
    RGBA specular = RGBA.white;
    float shininess = 32;
    float gloss = 0;

    bool isBindDiffuseMap = true;
    bool isBindSpecularMap = true;
    bool isBindNormalMap = true;
    bool isBindDispMap = true;

    protected
    {
        string diffuseMapPath;
        string specularMapPath;
        string normalMapPath;
        string dispMapPath;
    }

    this(string diffuseMapPath, string specularMapPath = null, string normalMapPath = null, string dispMapPath = null)
    {
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;
        this.normalMapPath = normalMapPath;
        this.dispMapPath = dispMapPath;

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

        if (!dispMap)
        {
            if (dispMapPath.length > 0)
            {
                dispMap = new TextureGPU;
                build(dispMap);
                dispMap.create(dispMapPath);
                addCreate(dispMap);
            }
        }
        else
        {
            addCreate(dispMap);
        }
    }
}
