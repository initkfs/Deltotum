module api.dm.kit.scenes.postprocess.bloom.bloom;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;

/**
 * Authors: initkfs
 */

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

class Bloom : Sprite3d
{
    SDL_GPUTexture* bloomA;
    SDL_GPUSampler* bloomSampler;
    SDL_GPUTexture* bloomB;

    SdlGPUPipeline brightPipeline;
    SdlGPUPipeline blurPipeline;
    SdlGPUPipeline composePipeline;
    uint bloomW;
    uint bloomH;

    float[4] brightUniformData;

    struct BlurUniformData
    {
        float[4] data;
    align(4):
        float radius = 1; // radius,  1.0
        float intensity = 1; // luma 1.0
    }

    struct ShaderFlags
    {
        uint isColorTint : 1;
        uint isColorEffects : 1;
        uint unused1 : 1;
        uint isVignette : 1;
        uint padding : 28;
    }

    struct ComposeUniformData
    {
    align(16):
        float[4] colorFilterData; //Color + intensity 0..1
        float[4] colorFlashData;
    align(4):
        float baseIntensity = 2;
        float bloomIntensity = 1;
        float exposure = 0.9;
        float threshold = 50;
        
        float contrast = 1;
        float saturation = 1;
        float vignette = 0;
        ShaderFlags flags;
    }

    ComposeUniformData composeUniformData;
    BlurUniformData blurUniformData;

    static assert(ShaderFlags.sizeof == 4);

    this()
    {
        brightUniformData = [1, 0.3, 0, 0];

        composeUniformData.colorFilterData = [1, 1, 1, 0];
        composeUniformData.colorFlashData = [0, 0, 0, 0];
    }

    override void create()
    {
        super.create;

        bloomW = window.widthu / 16;
        bloomH = window.heightu / 16;

        SDL_GPUTextureCreateInfo bloomInfo;
        bloomInfo.type = SDL_GPU_TEXTURETYPE_2D;
        bloomInfo.width = bloomW;
        bloomInfo.height = bloomH;
        bloomInfo.layer_count_or_depth = 1;
        bloomInfo.num_levels = 1;
        bloomInfo.format = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;
        bloomInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;

        bloomA = gpu.dev.newTexture(&bloomInfo);
        bloomB = gpu.dev.newTexture(&bloomInfo);

        SDL_GPURasterizerState raster;
        raster.fill_mode = SDL_GPU_FILLMODE_FILL;
        raster.cull_mode = SDL_GPU_CULLMODE_NONE;

        SDL_GPUDepthStencilState depth;
        depth.enable_depth_test = false;
        depth.enable_depth_write = false;

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;
        targetInfo.num_color_targets = 1;
        SDL_GPUColorTargetDescription colorDesc;
        colorDesc.format = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;
        colorDesc.blend_state.enable_blend = false;
        targetInfo.color_target_descriptions = &colorDesc;

        import std.path : buildPath;

        auto shaderDir = buildPath(context.app.dataDir, "shaders", "out", "spirv");

        ComPipelineBuffers glowBuffers;
        glowBuffers.numFragSamples = 1;
        glowBuffers.numFragUniformBuffers = 1;

        brightPipeline = gpu.newPipeline(
            buildPath(shaderDir, "FullQuad.vert.spv"),
            buildPath(shaderDir, "Bright.frag.spv"),
            glowBuffers,
            &targetInfo,
            &raster,
            &depth,
            "BrightPassPipeline",
            null,
            false,
            false
        );

        blurPipeline = gpu.newPipeline(
            buildPath(shaderDir, "FullQuad.vert.spv"),
            buildPath(shaderDir, "Blur.frag.spv"),
            glowBuffers,
            &targetInfo,
            &raster,
            &depth,
            "BlurPassPipeline",
            null,
            false,
            false
        );

        //colorDesc.format = gpu.getSwapchainTextureFormat;

        ComPipelineBuffers composeBuffers;
        composeBuffers.numFragSamples = 2;
        composeBuffers.numFragUniformBuffers = 1;

        composePipeline = gpu.newPipeline(
            buildPath(shaderDir, "FullQuad.vert.spv"),
            buildPath(shaderDir, "Compose.frag.spv"),
            composeBuffers,
            &targetInfo,
            &raster,
            &depth,
            "BlurComposePassPipeline",
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
        samplerInfo.address_mode_w = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;

        bloomSampler = gpu.dev.newSampler(&samplerInfo);

        composeUniformData.flags.isColorTint  = false;
        composeUniformData.flags.isColorEffects = false;
        composeUniformData.flags.isVignette = false;
    }

    void process(SDL_GPUTexture* resultTexture, SDL_GPUTexture* renderTexture, bool isMix2d3dMode,)
    {
        uint w = window.widthu;
        uint h = window.heightu;

        //Bright Pass
        //Horizontal Blur
        //Vertical Blur
        SDL_GPUColorTargetInfo[1] targets;

        SDL_GPUColorTargetInfo brightPassTarget;
        brightPassTarget.texture = bloomA;
        brightPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
        brightPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
        brightPassTarget.cycle = true;
        brightPassTarget.store_op = SDL_GPU_STOREOP_STORE;
        targets[0] = brightPassTarget;

        import api.math.geom2.rect2 : Rect2f;

        gpu.dev.beginRenderPass(targets);
        gpu.dev.setViewport(Rect2f(0, 0, bloomW, bloomH), 0, 1);
        gpu.dev.bindPipeline(brightPipeline);
        gpu.dev.bindFragmentSamplers(resultTexture, bloomSampler, 0);

        gpu.dev.pushUniformFragmentData(0, brightUniformData.ptr, brightUniformData.sizeof);

        gpu.dev.draw(3, 1, 0, 0);
        gpu.dev.endRenderPass(isSubmit : false);

        SDL_GPUColorTargetInfo horizontPassTarget;
        horizontPassTarget.texture = bloomB;
        horizontPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
        horizontPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
        horizontPassTarget.store_op = SDL_GPU_STOREOP_STORE;
        horizontPassTarget.cycle = true;
        targets[0] = horizontPassTarget;

        gpu.dev.beginRenderPass(targets);
        gpu.dev.bindPipeline(blurPipeline);

        blurUniformData.data = [1, 0, 1.0 / bloomW, 1.0 / bloomH];

        gpu.dev.pushUniformFragmentData(0, &blurUniformData, blurUniformData.sizeof);
        gpu.dev.bindFragmentSamplers(bloomA, bloomSampler, 0);
        gpu.dev.draw(3, 1, 0, 0);
        gpu.dev.endRenderPass(isSubmit : false);

        SDL_GPUColorTargetInfo vertPassTarget;
        vertPassTarget.texture = bloomA;
        vertPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
        vertPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
        vertPassTarget.store_op = SDL_GPU_STOREOP_STORE;
        vertPassTarget.cycle = true;
        targets[0] = vertPassTarget;

        gpu.dev.beginRenderPass(targets);
        gpu.dev.bindPipeline(blurPipeline);

        blurUniformData.data = [0, 1, 1.0 / bloomW, 1.0 / bloomH];

        gpu.dev.pushUniformFragmentData(0, &blurUniformData, blurUniformData.sizeof);
        gpu.dev.bindFragmentSamplers(bloomB, bloomSampler, 0);
        gpu.dev.draw(3, 1, 0, 0);
        gpu.dev.endRenderPass(isSubmit : false);

        SDL_GPUColorTargetInfo composePassTarget;
        composePassTarget.texture = isMix2d3dMode ? renderTexture : gpu.dev.swapchain;
        composePassTarget.load_op = SDL_GPU_LOADOP_DONT_CARE;
        composePassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
        composePassTarget.store_op = SDL_GPU_STOREOP_STORE;
        composePassTarget.cycle = true;
        targets[0] = composePassTarget;

        gpu.dev.beginRenderPass(targets);
        gpu.dev.setViewport(Rect2f(0, 0, window.widthu, window.heightu), 0, 1);
        gpu.dev.bindPipeline(composePipeline);

        gpu.dev.pushUniformFragmentData(0, &composeUniformData, composeUniformData.sizeof);

        gpu.dev.bindFragmentSamplers(resultTexture, bloomSampler, 0);
        gpu.dev.bindFragmentSamplers(bloomA, bloomSampler, 1);
        gpu.dev.draw(3, 1, 0, 0);
    }

    override void dispose()
    {
        super.dispose;

        if (bloomA)
        {
            gpu.dev.deleteTexture(bloomA);
        }

        if (bloomSampler)
        {
            gpu.dev.deleteSampler(bloomSampler);
        }

        if (bloomB)
        {
            gpu.dev.deleteTexture(bloomB);
        }

        if (brightPipeline)
        {
            brightPipeline.dispose;
        }

        if (blurPipeline)
        {
            blurPipeline.dispose;
        }

        if (composePipeline)
        {
            composePipeline.dispose;
        }
    }
}
