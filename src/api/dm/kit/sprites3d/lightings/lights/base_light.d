module api.dm.kit.sprites3d.lightings.lights.base_light;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;

import api.math.geom3.vec3: Vec3f;

/**
 * Authors: initkfs
 */
class BaseLight : Sprite3d
{
    Sprite3d mesh;

    bool isCreateMesh = true;

    Vec3f ambient = Vec3f(0.5f, 0.5f, 0.5f);
    Vec3f diffuse = Vec3f(0.7f, 0.7f, 0.7f);
    Vec3f specular = Vec3f(1.0f, 1.0f, 1.0f);

    Vec3f direction;
    Vec3f lightDirection;

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
