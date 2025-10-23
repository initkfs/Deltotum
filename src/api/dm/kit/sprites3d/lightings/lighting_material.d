module api.dm.kit.sprites3d.lightings.lighting_material;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.textures.texture3d : Texture3d;

import api.math.geom2.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class LightingMaterial : Sprite3d
{
    Texture3d diffuseMap;
    Texture3d specularMap;

    Vec3f ambient;
    Vec3f diffuse;
    Vec3f specular;
    Vec3f color;
    float shininess = 32;

    protected
    {
        string diffuseMapPath;
        string specularMapPath;
    }

    this(string diffuseMapPath, string specularMapPath)
    {
        assert(diffuseMapPath.length > 0);
        assert(specularMapPath.length > 0);
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;
    }

    override void create()
    {
        super.create;

        if (!diffuseMap)
        {
            diffuseMap = new Texture3d;
            build(diffuseMap);
            if (diffuseMapPath.length == 0)
            {
                throw new Exception("Diffuse map path must not be empty");
            }
            diffuseMap.create(diffuseMapPath);
            addCreate(diffuseMap);
        }

        if (!specularMap)
        {
            specularMap = new Texture3d;
            build(specularMap);
            if (specularMapPath.length == 0)
            {
                throw new Exception("Specural map path must not be empty");
            }
            specularMap.create(specularMapPath);
            addCreate(specularMap);
        }
    }

    bool bindTextures()
    {
        if (diffuseMap && specularMap)
        {
            Texture3d[2] textures = [diffuseMap, specularMap];
            gpu.dev.bindFragmentSamplers(textures);
            return true;
        }
        return false;
    }

    override void bindAll()
    {
        bindTextures;
    }

}
