module api.dm.kit.scenes.antialiasings.fxaa;

import api.dm.kit.scenes.antialiasings.antialiaser: AntiAliaser;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class FXAA : AntiAliaser
{
    SdlGPUPipeline fxaa;

    float[4] rcpFrame;

    override void create()
    {
        super.create;

        rcpFrame = 0;

        import std.path : buildPath;

        auto shaderDir = buildPath(context.app.dataDir, "shaders", "out", "spirv");

        ComPipelineBuffers aaBuffers;
        aaBuffers.numFragSamples = 1;
        aaBuffers.numFragUniformBuffers = 1;

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;
        targetInfo.num_color_targets = 1;

        SDL_GPUColorTargetDescription colorDesc;
        colorDesc.format = textureFormat;
        colorDesc.blend_state.enable_blend = false;
        targetInfo.color_target_descriptions = &colorDesc;

        SDL_GPURasterizerState raster;
        raster.fill_mode = SDL_GPU_FILLMODE_FILL;
        raster.cull_mode = SDL_GPU_CULLMODE_NONE;

        SDL_GPUDepthStencilState depth;
        depth.enable_depth_test = false;
        depth.enable_depth_write = false;

        fxaa = gpu.newPipeline(
            buildPath(shaderDir, "FullQuad.vert.spv"),
            buildPath(shaderDir, "Fxaa.frag.spv"),
            aaBuffers,
            &targetInfo,
            &raster,
            &depth,
            "FXAAPipeline",
            null,
            false,
            false
        );

        SDL_GPUSamplerCreateInfo samplerInfo;
        samplerInfo.min_filter = SDL_GPU_FILTER_LINEAR;
        samplerInfo.mag_filter = SDL_GPU_FILTER_LINEAR;
        samplerInfo.mipmap_mode = SDL_GPU_SAMPLERMIPMAPMODE_LINEAR;
        samplerInfo.address_mode_u = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;
        samplerInfo.address_mode_v = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;

        sampler = gpu.dev.newSampler(&samplerInfo);

        SDL_GPUTextureCreateInfo outInfo;
        outInfo.type = SDL_GPU_TEXTURETYPE_2D;
        outInfo.width = window.widthu;
        outInfo.height = window.heightu;
        outInfo.layer_count_or_depth = 1;
        outInfo.num_levels = 1;
        outInfo.format = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;
        outInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;

        texture = gpu.dev.newTexture(&outInfo);

        rcpFrame[0] = 1.0 / window.width;
        rcpFrame[1] = 1.0 / window.height;

    }

    override void process(SDL_GPUTexture* inTexture, SDL_GPUTexture* outTexture, bool isMix2d3dMode)
    {
        SDL_GPUColorTargetInfo[1] targets;
        SDL_GPUColorTargetInfo fxaaPassTarget;
        fxaaPassTarget.texture = outTexture;
        fxaaPassTarget.load_op = SDL_GPU_LOADOP_DONT_CARE;
        fxaaPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
        fxaaPassTarget.cycle = true;
        fxaaPassTarget.store_op = SDL_GPU_STOREOP_STORE;

        targets[0] = fxaaPassTarget;
        gpu.dev.beginRenderPass(targets);
        gpu.dev.bindPipeline(fxaa);
        gpu.dev.bindFragmentSamplers(texture, sampler, 0);

        //TODO output bounds?
        rcpFrame[0] = 1.0 / window.width;
        rcpFrame[1] = 1.0 / window.height;

        gpu.dev.pushUniformFragmentData(0, &rcpFrame, rcpFrame.sizeof);
        gpu.dev.draw(3, 1, 0, 0);
        gpu.dev.endRenderPass(isSubmit : false);
    }

    override void dispose()
    {
        super.dispose;
        if (fxaa)
        {
            fxaa.dispose;
        }
    }

}
