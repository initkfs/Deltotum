module api.dm.kit.sprites3d.pipelines.pipeline_group;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

import api.dm.back.sdl3.externs.csdl3;

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

    void createPipeline(
        uint numVertexSamples = 0,
        uint numVertexStorageBuffers = 0,
        uint numVertexUniformBuffers = 0,
        uint numVertexStorageTextures = 0,
        uint numFragSamples = 0,
        uint numFragStorageBuffers = 0,
        uint numFragUniformBuffers = 0,
        uint numFragStorageTextures = 0,
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
            numVertexSamples,
            numVertexStorageBuffers,
            numVertexUniformBuffers,
            numVertexStorageTextures,
            numFragSamples,
            numFragStorageBuffers,
            numFragUniformBuffers,
            numFragStorageTextures,
            rasterState,
            stencilState,
            colorDesc);

        if (!_pipeline)
        {
            throw new Exception("Pipeline is null");
        }

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
