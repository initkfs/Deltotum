module api.dm.kit.sprites3d.phong_sprite3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.kit.sprites3d.textures.texture3d : Texture3d;
import Math = api.math;

/**
 * Authors: initkfs
 */
class PhongSprite3d : Sprite3d
{
    Shape3d mesh;
    Texture3d diffuseMap;
    Texture3d specularMap;

    protected
    {
        string diffupseMapPath;
        string specularMapPath;
    }

    this(string diffupseMapPath, string specularMapPath)
    {
        this.diffupseMapPath = diffupseMapPath;
        this.specularMapPath = specularMapPath;
    }

    override void create()
    {
        super.create;

        if (mesh)
        {
            addCreate(mesh);
        }

        if (!diffuseMap)
        {
            diffuseMap = new Texture3d;
            build(diffuseMap);
            if (diffupseMapPath.length > 0)
            {
                diffuseMap.create(diffupseMapPath);
            }
            addCreate(diffuseMap);
        }

        if (!specularMap)
        {
            specularMap = new Texture3d;
            build(specularMap);
            if (specularMapPath.length > 0)
            {
                specularMap.create(specularMapPath);
            }
            addCreate(specularMap);
        }
    }

    void bindTextures()
    {
        Texture3d[2] textures = [diffuseMap, specularMap];
        gpu.dev.bindFragmentSamplers(textures);
    }

    void uploadStart()
    {
        assert(mesh);
        mesh.uploadStart;
        if (diffuseMap)
        {
            diffuseMap.uploadStart;
        }
        if (specularMap)
        {
            specularMap.uploadStart;
        }
    }

    void uploadEnd()
    {
        assert(mesh);
        mesh.uploadEnd;
        if (diffuseMap)
        {
            diffuseMap.uploadEnd;
        }
        if (specularMap)
        {
            specularMap.uploadEnd;
        }
    }

    void bindBuffers()
    {
        assert(mesh);
        mesh.bindBuffers;
    }

    void drawIndexed()
    {
        assert(mesh);
        mesh.drawIndexed;
    }
}
