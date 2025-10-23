module api.dm.kit.sprites3d.lightings.lights.base_light;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;

/**
 * Authors: initkfs
 */
class BaseLight : Sprite3d
{
    Sprite3d mesh;

    override void create()
    {
        super.create;

        if (mesh && !mesh.isCreated)
        {
            if (auto shape = cast(Shape3d) mesh)
            {
                shape.isCreateLightingMaterial = false;
            }

            addCreate(mesh);
        }
    }
}
