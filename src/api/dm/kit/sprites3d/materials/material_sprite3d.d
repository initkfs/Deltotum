module api.dm.kit.sprites3d.materials.material_sprite3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.materials.material : Material;

/**
 * Authors: initkfs
 */

class MaterialSprite3d : Sprite3d
{

    Material material;
    bool isCreateMaterial;
    bool isShareMaterial;

    string diffuseMapPath;
    string specularMapPath;
    string normalMapPath;
    string dispMapPath;
    string aoMapPath;

    override void create()
    {
        super.create;

        if (!material)
        {
            if (isCreateMaterial)
            {
                import api.dm.kit.sprites3d.materials.material : Material;

                material = new Material(diffuseMapPath, specularMapPath, normalMapPath, dispMapPath, aoMapPath);
                addCreate(material);
            }
        }
        else
        {
            addCreate(material);
        }
    }

    bool hasMaterial() => material !is null;

    void onMaterial(scope void delegate(Material) onMaterialIfExists)
    {
        if (!material)
        {
            return;
        }

        onMaterialIfExists(material);
    }

    override void dispose()
    {
        if (material && isShareMaterial)
        {
            remove(material);
            material = null;
        }

        super.dispose;
    }
}
