module api.dm.sim3d.materials.material;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.textures.tex3d : Tex3d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;

/**
 * Authors: initkfs
 */

class Material : Sprite3d
{
    Tex3d diffuseMap;
    Tex3d specularMap;
    Tex3d normalMap;
    Tex3d dispMap;
    Tex3d aoMap;

    RGBA ambient = RGBA.white;
    RGBA specular = RGBA.white;
    float shininess = 256;
    float gloss = 0.45;

    bool isBindDiffuseMap = true;
    bool isBindSpecularMap = true;
    bool isBindNormalMap = true;
    bool isBindDispMap = true;
    bool isBindAoMap = true;

    string diffuseMapPath;
    string specularMapPath;
    string normalMapPath;
    string dispMapPath;
    string aoMapPath;

    //TODO auto mip maps w\h > 16
    bool isMipMaps = true;

    bool isSharedMaterial;

    this(string diffuseMapPath = null, string specularMapPath = null, string normalMapPath = null, string dispMapPath = null, string aoMapPath = null)
    {
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;
        this.normalMapPath = normalMapPath;
        this.dispMapPath = dispMapPath;
        this.aoMapPath = aoMapPath;

        id = "LightMaterial";
    }

    override void create()
    {
        super.create;

        if (!diffuseMap)
        {
            if (diffuseMapPath.length > 0)
            {
                diffuseMap = new Tex3d;
                diffuseMap.isMipMaps = isMipMaps;
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
                specularMap = new Tex3d;
                specularMap.isMipMaps = isMipMaps;
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
                normalMap = new Tex3d;
                normalMap.isMipMaps = isMipMaps;
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
                dispMap = new Tex3d;
                dispMap.isMipMaps = isMipMaps;
                build(dispMap);
                dispMap.create(dispMapPath);
                addCreate(dispMap);
            }
        }
        else
        {
            addCreate(dispMap);
        }

        if (!aoMap)
        {
            if (aoMapPath.length > 0)
            {
                aoMap = new Tex3d;
                aoMap.isMipMaps = isMipMaps;
                build(aoMap);
                aoMap.create(aoMapPath);
                addCreate(aoMap);
            }
        }
        else
        {
            addCreate(aoMap);
        }
    }
}
