module api.dm.sim3d.diffusions.diffusion_pass;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.sim3d.diffusions.textures.diffusion_tex_array : DiffusionTexArray;

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

struct DiffusionParams
{
    float deltaTime = 0; //0.016
    float conductivity = 1; //1
    float coolingRate = 1;
    float ambientTemp = 20;
    float[4] updateXY = 0;
}

/**
 * Authors: initkfs
 */
class DiffusionPass : Sprite3d
{
    DiffusionTexArray diffusionMaps1;
    DiffusionTexArray diffusionMaps2;
    bool isReadMap1 = true;
    bool isDiffusionMap = true;

    SDL_GPUComputePipeline* diffusionPipeline;

    DiffusionParams params;

    DiffusionTexArray outputTexture;

    this()
    {
        //isPushUniformVertexMatrix = false;
        isForGraphicsPipeLine = false;
    }

    override void create()
    {
        super.create;

        diffusionMaps1 = new DiffusionTexArray;
        buildInitCreate(diffusionMaps1);

        diffusionMaps2 = new DiffusionTexArray;
        buildInitCreate(diffusionMaps2);

        import api.dm.com.graphics.gpu.com_pipeline : ComComputeBuffers;

        ComComputeBuffers buffs;
        buffs.numRTextures = 1;
        buffs.numRWTextures = 1;
        buffs.numUniforms = 1;

        import std.path : buildPath;
    
        // gpu.dev.startCopyPass;
        // diffusionMaps1.uploadStart;
        // diffusionMaps2.uploadStart;
        // gpu.dev.endCopyPass;

        auto compShaderPath = buildPath(context.app.dataDir, "shaders", "out", "spirv", "HeatCompute.comp.spv");
        diffusionPipeline = gpu.dev.createComputePipelineSPIRV(compShaderPath, buffs);

        gpu.dev.startCopyPass;
        if (diffusionMaps1)
        {
            diffusionMaps1.uploadStart;
        }

        if (diffusionMaps2)
        {
            diffusionMaps2.uploadStart;
        }
        gpu.dev.endCopyPass;
        if (diffusionMaps1)
        {
            diffusionMaps1.uploadEnd;
        }

        if (diffusionMaps2)
        {
            diffusionMaps2.uploadEnd;
        }
    }

    DiffusionTexArray diffusionInput() => isReadMap1 ? diffusionMaps1 : diffusionMaps2;

    override bool draw(float at)
    {
        SDL_GPUStorageTextureReadWriteBinding rwBinding;
        auto outHeatTexture = isReadMap1 ? diffusionMaps2.texture : diffusionMaps1.texture;
        rwBinding.texture = outHeatTexture;
        rwBinding.mip_level = 0;
        rwBinding.layer = 0;
        rwBinding.cycle = true;

        gpu.dev.startComputePass(&rwBinding, null, 1, 0);
        gpu.dev.bindComputePipeline(diffusionPipeline);

        params.deltaTime = 1.0 / window.frameRate;

        //params.updateXY = [7, 15, 0, 10000];

        gpu.dev.pushComputeUniform(&params, params.sizeof, 0);

        outputTexture = isReadMap1 ? diffusionMaps1 : diffusionMaps2;
        auto inputGpu = outputTexture.texture;
        gpu.dev.bindComputeStorageTextures(&inputGpu);

        isReadMap1 = !isReadMap1;

        size_t numThreads = 16;
        uint threadsCount = diffusionMaps1.widthu / numThreads;
        uint groupCountX = threadsCount;
        uint groupCountY = threadsCount;
        uint groupCountZ = 3;
        gpu.dev.dispatchCompute(groupCountX, groupCountY, groupCountZ);
        gpu.dev.endComputePass;

        return true;
    }

    override void dispose()
    {
        super.dispose;

        if (diffusionMaps1)
        {
            diffusionMaps1.dispose;
        }

        if (diffusionMaps2)
        {
            diffusionMaps2.dispose;
        }

        if (diffusionPipeline)
        {
            gpu.dev.deleteComputePipeline(diffusionPipeline);
        }
    }
}
