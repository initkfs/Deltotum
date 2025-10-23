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

    override void create(){
        super.create;

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = gpu.getSwapchainTextureFormat;
        targetInfo.num_color_targets = 1;
        targetInfo.color_target_descriptions = targetDesc.ptr;
        targetInfo.has_depth_stencil_target = true;
        targetInfo.depth_stencil_format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;

        auto stencilState = gpu.dev.depthStencilState;
        auto rastState = gpu.dev.depthRasterizerState;

        createPipeline(0, 0, 1, 0, 0, 0, 1, 0, &rastState, &stencilState, &targetInfo);
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
