module api.dm.kit.sprites3d.lightings.lights.base_light;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.materials.material_sprite3d : MaterialSprite3d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */
class BaseLight : Sprite3d
{
    bool isCreateMesh = true;
    MaterialSprite3d mesh;

    //Vec3f ambient = Vec3f(0.5f, 0.5f, 0.5f);
    //Vec3f diffuse = Vec3f(0.7f, 0.7f, 0.7f);
    //Vec3f specular = Vec3f(1.0f, 1.0f, 1.0f);
    RGBA ambient = RGBA.white;
    RGBA diffuse = RGBA.white;
    RGBA specular = RGBA.white;

    Vec3f direction;
    //Vec3f lightDirection;

    Sprite3d target;

    float radius = 15;
    float linearCoeff = 0.09;
    float quadraticCoeff = 0;

    this()
    {
        id = "BaseLight";
        albedo = RGBA.white;
    }

    override void create()
    {
        super.create;

        if (!mesh)
        {
            if (isCreateMesh)
            {
                import api.dm.kit.sprites3d.shapes.sphere : Sphere;

                Sphere newMesh = new Sphere(0.5);
                newMesh.isCreateMaterial = false;
                newMesh.id = "LightShape";
                mesh = newMesh;
                mesh.scale = Vec3f(0.2, 0.2, 0.2);
                mesh.isManaged = true;
            }
        }
        else
        {
            if (!mesh.isCreated)
            {
                mesh.isCreateMaterial = false;
            }
        }

        if (mesh)
        {
            addCreate(mesh);
        }
    }

    override void update(float dt)
    {
        super.update(dt);

        if (target)
        {
            direction = (target.pos3 - pos3).normalize;
        }
    }
}
