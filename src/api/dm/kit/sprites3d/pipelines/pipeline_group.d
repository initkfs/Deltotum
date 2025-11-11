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

    string toString() const
    {
        import std.format : format;

        return format("VertexSample:%d, VertexStorage:%d, VertexUniform:%d, VertexStorageTexture:%d, FragSample:%d, FragStorage:%d, FragUniform:%d, FragStorageTexture:%d", numVertexSamples, numVertexStorageBuffers, numVertexUniformBuffers, numVertexStorageTextures, numFragSamples, numFragStorageBuffers, numFragUniformBuffers, numFragStorageTextures);
    }
}

struct SimpleDataBuffer
{
    float[4] value1;
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

        bool _hasSprites;
    }

    string vertexShaderName;
    string fragmentShaderName;

    bool isDepth = true;
    bool isCreateDataBuffer;
    bool isBindForEmptyChildren;

    SDL_GPUBuffer* dataBufferPtr;
    SDL_GPUTransferBuffer* dataTransferBufferPtr;

    this()
    {
        isPushUniformVertexMatrix = false;
    }

    override void create()
    {
        super.create;

        if (isCreateDataBuffer)
        {
            dataBufferPtr = gpu.dev.newGPUBuffer(SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ, SimpleDataBuffer
                    .sizeof);
            gpu.dev.setGPUBufferName(dataBufferPtr, "DataBuffer");
            dataTransferBufferPtr = gpu.dev.newTransferDownloadBuffer(SimpleDataBuffer.sizeof);
        }
    }

    override bool draw()
    {
        foreach (pipe; childPipelines)
        {
            if (pipe.bindPipeline)
            {
                if (pipe.isCreateDataBuffer)
                {
                    pipe.bindDataBuffer;
                }
                pipe.draw;
            }

        }

        if (bindPipeline)
        {
            if (isCreateDataBuffer)
            {
                bindDataBuffer;
            }
            return super.draw;
        }

        return false;
    }

    override void bindAll()
    {
        super.bindAll;
    }

    void bindDataBuffer()
    {
        gpu.dev.bindFragmentStorageBuffer(dataBufferPtr);
    }

    bool bindPipeline()
    {
        //assert(_pipeline);
        if(!_pipeline){
            return false;
        }

        if (((!_hasSprites) || children.length == 0) && !isBindForEmptyChildren)
        {
            return false;
        }

        gpu.dev.bindPipeline(_pipeline);
        return true;
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
        else
        {
            if (!_hasSprites)
            {
                //TODO on remove
                _hasSprites = true;
            }
        }
    }

    PipelineBuffers pipeBuffers()
    {
        PipelineBuffers buffers;
        if (isCreateDataBuffer)
        {
            buffers.numFragStorageBuffers = 1;
        }
        return buffers;
    }

    void createPipelineFull(
        in PipelineBuffers buffers,
        SDL_GPURasterizerState* rasterState = null,
        SDL_GPUDepthStencilState* stencilState = null,
        SDL_GPUGraphicsPipelineTargetInfo* colorDesc = null
    )
    {
        assert(!_pipeline, "Found old pipeline");

        assert(vertexShaderName.length > 0);
        assert(
            fragmentShaderName.length > 0);

        auto vertShaderPath = gpu.shaderDefaultPath(
            vertexShaderName);
        auto fragShaderPath = gpu.shaderDefaultPath(
            fragmentShaderName);

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
        targetInfo.color_target_descriptions = targetDesc
            .ptr;
        if (isDepth)
        {
            targetInfo.has_depth_stencil_target = true;
            targetInfo.depth_stencil_format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;
        }

        auto stencilState = isDepth ? gpu.dev.depthStencilState : gpu.dev.stencilState;
        auto rastState = isDepth ? gpu.dev
            .depthRasterizerState : gpu.dev.rasterizerState;

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

    SimpleDataBuffer downloadData()
    {
        gpu.dev.startCopyPass;
        gpu.dev.downloadBuffer(dataBufferPtr, dataTransferBufferPtr, SimpleDataBuffer.sizeof);
        gpu.dev.endCopyPass(true);

        SimpleDataBuffer dataBuffer;
        auto dataBuffPtr = cast(SimpleDataBuffer*) gpu.dev.mapTransferBuffer(dataTransferBufferPtr);
        dataBuffer.value1 = (*dataBuffPtr).value1;
        gpu.dev.unmapTransferBuffer(dataTransferBufferPtr);
        return dataBuffer;
    }

    override void dispose()
    {
        super.dispose;
        if (_pipeline)
        {
            gpu.dev.deletePipeline(_pipeline);
        }

        if (dataBufferPtr)
        {
            gpu.dev.deleteGPUBuffer(dataBufferPtr);
            dataBufferPtr = null;
        }

        if (dataTransferBufferPtr)
        {
            gpu.dev.deleteTransferBuffer(dataTransferBufferPtr);
            dataTransferBufferPtr = null;
        }
    }

}
