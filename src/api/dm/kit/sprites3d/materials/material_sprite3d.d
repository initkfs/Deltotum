module api.dm.kit.sprites3d.materials.material_sprite3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.materials.material : Material;

/**
 * Authors: initkfs
 */

class MaterialSprite3d : Sprite3d
{
    protected
    {
        Material _material;
    }

    bool isCreateMaterial;
    bool isDrawWithSharedMaterial;

    string diffuseMapPath;
    string specularMapPath;
    string normalMapPath;
    string dispMapPath;
    string aoMapPath;

    override void create()
    {
        super.create;

        if (!_material)
        {
            if (isCreateMaterial)
            {
                import api.dm.kit.sprites3d.materials.material : Material;

                _material = new Material(diffuseMapPath, specularMapPath, normalMapPath, dispMapPath, aoMapPath);
                addCreate(_material);
            }
        }
        else
        {
            addCreate(_material);
        }
    }

    void onMaterial(scope void delegate(Material) onMaterialIfExists)
    {
        if (!_material)
        {
            return;
        }

        onMaterialIfExists(_material);
    }

    bool hasMaterial() => _material !is null;
    Material material()
    {
        if (!_material)
        {
            throw new Exception("Material is null");
        }
        return _material;
    }

    void material(Material m)
    {
        _material = m;

        if (m.isSharedMaterial && !isDrawWithSharedMaterial)
        {
            isCanDrawSelf = false;
            pipeline.addSharedMaterialSprite(this);
        }
    }

    override void dispose()
    {
        if (_material && _material.isSharedMaterial)
        {
            pipeline.removeSharedMatSprite(this);

            remove(_material);
            _material = null;
        }

        super.dispose;
    }
}
