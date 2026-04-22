module api.dm.kit.sprites3d.pipelines.pipeline_group;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;

import api.dm.back.sdl3.externs.csdl3;

struct SimpleDataBuffer
{
    float[4] value1;
}

/**
 * Authors: initkfs
 */

class PipelineGroup : Sprite3d
{
    bool isBlend;

    protected
    {
        SdlGPUPipeline _pipeline;

        PipelineGroup[] childPipelines;

        bool _hasSprites;
    }

    bool isPushUniformVertexMatrix;

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

    override bool draw(float alpha)
    {
        foreach (pipe; childPipelines)
        {
            if (pipe.bindPipeline)
            {
                if (pipe.isCreateDataBuffer)
                {
                    pipe.bindDataBuffer;
                }
                pipe.draw(alpha);
            }

        }

        if (bindPipeline)
        {
            if (isCreateDataBuffer)
            {
                bindDataBuffer;
            }
            return super.draw(alpha);
        }

        return false;
    }

    void bindDataBuffer()
    {
        gpu.dev.bindFragmentStorageBuffer(dataBufferPtr);
    }

    bool bindPipeline()
    {
        //assert(_pipeline);
        if (!_pipeline)
        {
            return false;
        }

        if (((!_hasSprites) || children.length == 0) && !isBindForEmptyChildren)
        {
            return false;
        }

        gpu.dev.bindPipeline(_pipeline);

        //import api.math.geom2.rect2 : Rect2f;

        //TODO extract to scene?
        //gpu.dev.setViewport(Rect2f(-1, -1, 1, 1));

        return true;
    }

    override bool add(Sprite2d object, long index = -1)
    {
        if (!super.add(object, index))
        {
            return false;
        }

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

        return true;
    }

    ComPipelineBuffers pipeBuffers()
    {
        ComPipelineBuffers buffers;
        if (isCreateDataBuffer)
        {
            buffers.numFragStorageBuffers = 1;
        }
        return buffers;
    }

    void createPipeline(
        in ComPipelineBuffers buffers,
        SDL_GPUGraphicsPipelineTargetInfo* colorDesc = null,
        SDL_GPURasterizerState* rasterState = null,
        SDL_GPUDepthStencilState* stencilState = null,
        scope void delegate(
            ref SDL_GPUGraphicsPipelineCreateInfo) onPipeSettings = null
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
            buffers,
            colorDesc,
            rasterState,
            stencilState,
            id,
            onPipeSettings
            );
        if (!_pipeline)
        {
            throw new Exception("Pipeline is null");
        }
    }

    void createPipeline(ComPipelineBuffers buffers, scope void delegate(
            ref SDL_GPUGraphicsPipelineCreateInfo) onPipeSettings = null)
    {
        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = gpu.dev.pipelineTextureFormat;
        targetInfo.num_color_targets = 1;
        targetInfo.color_target_descriptions = targetDesc
            .ptr;
        if (isDepth)
        {
            targetInfo.has_depth_stencil_target = true;
            targetInfo.depth_stencil_format = gpu.dev.depthTextureFormat;
        }

        if (isBlend)
        {
            SDL_GPUColorTargetBlendState blendState;
            if (!gpu.dev.isA2C)
            {
                blendState.enable_blend = true;
            }

            blendState.src_color_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA,
            blendState.dst_color_blendfactor = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
            blendState.color_blend_op = SDL_GPU_BLENDOP_ADD,
            blendState.src_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ONE,
            blendState.dst_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ZERO,
            blendState.alpha_blend_op = SDL_GPU_BLENDOP_ADD;

            // blendState.color_write_mask = cast(ubyte) (SDL_GPU_COLORCOMPONENT_R |
            //     SDL_GPU_COLORCOMPONENT_G |
            //     SDL_GPU_COLORCOMPONENT_B |
            //     SDL_GPU_COLORCOMPONENT_A);

            targetDesc[0].blend_state = blendState;
        }

        auto stencilState = gpu.dev.depthStencilState;
        if (isBlend)
        {
            stencilState.enable_depth_write = false;
        }

        auto rastState = createRasterizerState;

        createPipeline(
            buffers,
            &targetInfo,
            &rastState,
            &stencilState,
            onPipeSettings);
    }

    SDL_GPURasterizerState createRasterizerState()
    {
        import KitConfig = api.dm.kit.kit_config_keys;

        bool isLineMode = config.getBoolIfHas(KitConfig.backendGPUShowLines);
        bool isCullDisable = config.getBoolIfHas(KitConfig.backendGPUDisableCull);

        auto fillMode = !isLineMode ? SDL_GPU_FILLMODE_FILL : SDL_GPU_FILLMODE_LINE;
        auto cullMode = !isCullDisable ? SDL_GPU_CULLMODE_BACK : SDL_GPU_CULLMODE_NONE;

        return gpu.dev.rasterizerState(fillMode, cullMode);
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
        gpu.dev.endCopyPass(true, true);

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
