module api.dm.kit.sprites3d.pipelines.pipeline_group;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

import api.dm.back.sdl3.externs.csdl3;

struct PipelineBuffers
{
    uint numVertexSamples;
    uint numVertexStorageBuffers;
    uint numVertexUniformBuffers;
    uint numVertexStorageTextures;
    uint numFragSamples;
    uint numFragStorageBuffers;
    uint numFragUniformBuffers;
    uint numFragStorageTextures;
}

/**
 * Authors: initkfs
 */

class PipelineGroup : Sprite3d
{
    protected
    {
        SdlGPUPipeline _pipeline;

        PipelineGroup[] childPipelines;
    }

    string vertexShaderName;
    string fragmentShaderName;

    bool isDepth = true;

    this()
    {
        isPushUniformVertexMatrix = false;
    }

    override bool draw()
    {
        foreach (pipe; childPipelines)
        {
            pipe.bindPipeline;
            pipe.draw;
        }

        bindPipeline;
        return super.draw;
    }

    void bindPipeline()
    {
        assert(_pipeline);
        gpu.dev.bindPipeline(_pipeline);
    }

    override void add(Sprite2d object, long index = -1)
    {
        super.add(object, index);

        if (auto pipeline = cast(PipelineGroup) object)
        {
            //TODO check exists
            childPipelines ~= pipeline;
            pipeline.isDrawByParent = false;
        }
    }

    PipelineBuffers pipeBuffers() => PipelineBuffers();

    void createPipelineFull(
        in PipelineBuffers buffers,
        SDL_GPURasterizerState* rasterState = null,
        SDL_GPUDepthStencilState* stencilState = null,
        SDL_GPUGraphicsPipelineTargetInfo* colorDesc = null
    )
    {

        assert(vertexShaderName.length > 0);
        assert(fragmentShaderName.length > 0);

        auto vertShaderPath = gpu.shaderDefaultPath(vertexShaderName);
        auto fragShaderPath = gpu.shaderDefaultPath(fragmentShaderName);

        _pipeline = gpu.newPipeline(
            vertShaderPath,
            fragShaderPath,
            buffers.numVertexSamples,
            buffers.numVertexStorageBuffers,
            buffers.numVertexUniformBuffers,
            buffers.numVertexStorageTextures,
            buffers.numFragSamples,
            buffers.numFragStorageBuffers,
            buffers.numFragUniformBuffers,
            buffers.numFragStorageTextures,
            rasterState,
            stencilState,
            colorDesc);

        if (!_pipeline)
        {
            throw new Exception("Pipeline is null");
        }
    }

    void createPipeline(in PipelineBuffers buffers)
    {
        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = gpu.getSwapchainTextureFormat;
        targetInfo.num_color_targets = 1;
        targetInfo.color_target_descriptions = targetDesc.ptr;

        if (isDepth)
        {
            targetInfo.has_depth_stencil_target = true;
            targetInfo.depth_stencil_format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;
        }

        auto stencilState = isDepth ? gpu.dev.depthStencilState : gpu.dev.stencilState;
        auto rastState = isDepth ? gpu.dev.depthRasterizerState : gpu.dev.rasterizerState;

        createPipelineFull(
            buffers,
            &rastState,
            &stencilState,
            &targetInfo);
    }

    SdlGPUPipeline pipeline()
    {
        assert(_pipeline);
        return _pipeline;
    }

    void pipeline(SdlGPUPipeline npipeline)
    {
        assert(npipeline, "New pipeline must not be null");
        _pipeline = npipeline;
    }

    override void dispose()
    {
        super.dispose;

        if (_pipeline)
        {
            gpu.dev.deletePipeline(_pipeline);
        }
    }

}
