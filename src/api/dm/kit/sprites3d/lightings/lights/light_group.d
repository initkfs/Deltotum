module api.dm.kit.sprites3d.lightings.lights.light_group;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.lightings.lights.base_light : BaseLight;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class LightGroup : PipelineGroup
{
    BaseLight[] lights;

    this()
    {
        vertexShaderName = "Light.vert";
        fragmentShaderName = "Light.frag";
    }

    override void create()
    {
        super.create;

        auto buffers = pipeBuffers;
        buffers.numFragUniformBuffers = 1;
        buffers.numVertexUniformBuffers = 1;

        createPipeline(buffers);
    }

    override void add(Sprite2d object, long index = -1)
    {
        super.add(object, index);

        if (auto light = cast(BaseLight) object)
        {
            foreach (oldLight; lights)
            {
                if (oldLight is light)
                {
                    return;
                }
            }

            lights ~= light;
        }
    }

    size_t length() => lights.length;

    override void pushUniforms()
    {
        super.pushUniforms;

        struct UniBuffer
        {
        align(16):
            float[4] planes;
            float[4] colors;
        }

        //TODO color
        UniBuffer buff = UniBuffer([camera.nearPlane, camera.farPlane, 0, 0], [
            0.5, 0.5, 0.5, 1
        ]);
        gpu.dev.pushUniformFragmentData(0, &buff, UniBuffer.sizeof);
    }
}
