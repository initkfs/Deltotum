module api.dm.kit.sprites3d.lightings.lighting_material;

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

    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
    Vec3f color;
    float shininess = 32;

    bool isBindDiffuseMap = true;
    bool isBindSpecularMap = true;

    protected
    {
        string diffuseMapPath;
        string specularMapPath;
    }

    this(string diffuseMapPath, string specularMapPath)
    {
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;
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
                if (diffuseMapPath.length == 0)
                {
                    throw new Exception("Diffuse map path must not be empty");
                }
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
                if (specularMapPath.length == 0)
                {
                    throw new Exception("Specural map path must not be empty");
                }
                specularMap.create(specularMapPath);
                addCreate(specularMap);
            }
        }
        else
        {
            addCreate(specularMap);
        }
    }

    bool bindTextures()
    {
    
        uint slot = 0;
        bool isBind;
        if (diffuseMap)
        {
            if (isBindDiffuseMap)
            {
                gpu.dev.bindFragmentSamplers(diffuseMap, slot);
                isBind |= true;
                slot++;
            }
        }
        else
        {
            gpu.dev.bindFragmentSamplers(gpu.defaultSpecular, slot);
            slot++;
            isBind |= true;
        }

        if (specularMap)
        {
            if (isBindSpecularMap)
            {
                gpu.dev.bindFragmentSamplers(specularMap, slot);
                slot++;
                isBind |= true;
            }
        }
        else
        {
            gpu.dev.bindFragmentSamplers(gpu.defaultSpecular, slot);
            slot++;
            isBind |= true;
        }

        //TODO maps
        gpu.dev.bindFragmentSamplers(gpu.defaultNormal, slot);
        slot++;
        gpu.dev.bindFragmentSamplers(gpu.defaultAO, slot);
        slot++;
        gpu.dev.bindFragmentSamplers(gpu.defaultEmission, slot);
        slot++;

        return isBind;
    }

    override void bindAll()
    {
        bindTextures;
    }

}
