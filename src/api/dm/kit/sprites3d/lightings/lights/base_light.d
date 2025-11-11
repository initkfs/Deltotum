module api.dm.kit.sprites3d.lightings.lights.base_light;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;

import api.math.geom2.vec3: Vec3f;

/**
 * Authors: initkfs
 */
class BaseLight : Sprite3d
{
    Sprite3d mesh;

    bool isCreateMesh = true;

    override void create()
    {
        super.create;

        if (!mesh)
        {
            if (isCreateMesh)
            {
                import api.dm.kit.sprites3d.shapes.sphere : Sphere;

                Sphere newMesh = new Sphere(0.5);
                mesh = newMesh;
                mesh.scale = Vec3f(0.2, 0.2, 0.2);
                newMesh.isCreateLightingMaterial = false;
                mesh.isManaged = true;
            }
        }
        else
        {
            if (!mesh.isCreated)
            {
                if (auto shape = cast(Shape3d) mesh)
                {
                    shape.isCreateLightingMaterial = false;
                }
            }
        }

        if (mesh)
        {
            addCreate(mesh);
        }
    }
}
