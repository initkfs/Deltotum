module api.dm.kit.sprites3d.pipelines.items.simple_group;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.math.geom2.vec3 : Vec3f;
import Math = api.math;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class SimpleGroup : PipelineGroup
{
    this()
    {
        super();
        vertexShaderName = "EnvFull.vert";
        fragmentShaderName = "EnvSimple.frag";
    }

    override void create()
    {
        super.create;

        auto buff = pipeBuffers;
        buff.numVertexUniformBuffers += 1;
        buff.numFragUniformBuffers += 1;
        createPipeline(buff);
    }

    override void pushUniforms()
    {
        super.pushUniforms;

        struct PlaneInfo
        {
        align(4):
            float nearPlane;
            float farPlane;
        }

        struct UniformData
        {
            PlaneInfo planeInfo;
        }

        UniformData planes = UniformData(PlaneInfo(camera.nearPlane, camera.farPlane));

        gpu.dev.pushUniformFragmentData(0, &planes, planes.sizeof);
    }
}
