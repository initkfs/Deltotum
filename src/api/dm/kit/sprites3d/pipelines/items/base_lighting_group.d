module api.dm.kit.sprites3d.pipelines.items.base_lighting_group;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.lightings.lights.light_group : LightGroup;

import api.math.geom2.vec3 : Vec3f;
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

        struct UniformData
        {
            PlaneInfo planeInfo;
        align(16):
            float[3] cameraPos;
            PhongData material;
            LightData[16] lights;
        align(4):
            uint lightCount;
        }

        UniformData planes = UniformData();

        planes.planeInfo.nearPlane = camera.nearPlane;
        planes.planeInfo.farPlane = camera.farPlane;

        planes.cameraPos = [
            camera.cameraPos.x, camera.cameraPos.y, camera.cameraPos.z
        ];

        planes.lightCount = cast(uint) lights.length;

        planes.material.ambient = Vec3f(1.0f, 0.5f, 0.31f);
        planes.material.diffuse = Vec3f(1.0f, 0.5f, 0.31f);
        planes.material.specular = Vec3f(0.5f, 0.5f, 0.5f);
        planes.material.shininess = 32;
        planes.material.color = Vec3f(1.0f, 0.5f, 0.31f);

        foreach (li; 0 .. planes.lightCount)
        {
            auto lamp = lights.lights[li];

            planes.lights[li].position = lamp.translatePos;
            planes.lights[li].direction = camera.cameraFront;
            planes.lights[li].ambient = Vec3f(0.2f, 0.2f, 0.2f);
            planes.lights[li].diffuse = Vec3f(0.7f, 0.7f, 0.7f);
            planes.lights[li].specular = Vec3f(1.0f, 1.0f, 1.0f);
            planes.lights[li].constant = 1.0;
            planes.lights[li].linear = 0.09f;
            planes.lights[li].quadratic = 0;
            planes.lights[li].type = 0;
            planes.lights[li].cutoff = Math.cosDeg(12.5);
            planes.lights[li].outerCutoff = Math.cosDeg(17.5);
        }

        gpu.dev.pushUniformFragmentData(0, &planes, planes.sizeof);
    }
}
