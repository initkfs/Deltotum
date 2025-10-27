module api.dm.kit.sprites3d.pipelines.items.base_lighting_group;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.lightings.lights.light_group : LightGroup;

import api.math.geom2.vec3: Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class BaseLightingGroup : PipelineGroup
{
    LightGroup lights;

    override void create()
    {
        super.create;

        lights = new LightGroup;
        addCreate(lights);
    }

    override void pushUniforms()
    {
        super.pushUniforms;

        import api.dm.kit.sprites3d.lightings.phongs.materials.material;

        struct PlaneInfo
        {
            float nearPlane;
            float farPlane;
        }

        struct Planes
        {
            PlaneInfo planeInfo;
        align(16):
            float[3] cameraPos;
            PhongData material;
            LightData light;
        }

        Planes planes = Planes();

        planes.planeInfo.nearPlane = camera.nearPlane;
        planes.planeInfo.farPlane = camera.farPlane;

        planes.cameraPos = [
            camera.cameraPos.x, camera.cameraPos.y, camera.cameraPos.z
        ];

        planes.material.ambient = Vec3f(1.0f, 0.5f, 0.31f);
        planes.material.diffuse = Vec3f(1.0f, 0.5f, 0.31f);
        planes.material.specular = Vec3f(0.5f, 0.5f, 0.5f);
        planes.material.shininess = 32;
        planes.material.color = Vec3f(1.0f, 0.5f, 0.31f);

        auto lamp = lights.lights[0];

        planes.light.position = lamp.translatePos;
        planes.light.direction = camera.cameraFront;
        planes.light.ambient = Vec3f(0.2f, 0.2f, 0.2f);
        planes.light.diffuse = Vec3f(0.7f, 0.7f, 0.7f);
        planes.light.specular = Vec3f(1.0f, 1.0f, 1.0f);
        planes.light.constant = 1.0;
        planes.light.linear = 0.09f;
        planes.light.quadratic = 0;
        planes.light.type = 0;
        planes.light.cutoff = Math.cosDeg(12.5);
        planes.light.outerCutoff = Math.cosDeg(17.5);

        gpu.dev.pushUniformFragmentData(0, &planes, planes.sizeof);
    }
}
