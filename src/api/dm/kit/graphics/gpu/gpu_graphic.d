module api.dm.kit.graphics.gpu.gpu_graphic;

import api.core.loggers.logging : Logging;
import api.dm.kit.windows.window : Window;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.core.utils.factories : ProviderFactory;

//TODO extract COM interfaces
import api.dm.back.sdl3.externs.csdl3;
import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

enum GPUGraphicState
{
    none,
    copyStart,
    renderStart
}

/**
 * Authors: initkfs
 */
class GPUGraphic : LoggableUnit
{
    protected
    {
        SdlGPUDevice _gpu;
        SDL_FColor clearColor;

        SDL_GPUCommandBuffer* lastCmdBuff;
        SDL_GPURenderPass* lastPass;
        SDL_GPUTexture* lastSwapchain;

        SDL_GPUCopyPass* lastCopyPass;

        GPUGraphicState state;
    }

    SDL_GPUCommandBuffer* cmdBuff() => lastCmdBuff;
    SDL_GPURenderPass* renderPass() => lastPass;
    SDL_GPUCopyPass* copyPass() => lastCopyPass;
    SDL_GPUTexture* swapchain() => lastSwapchain;

    bool isActive() => _gpu !is null;

    this(Logging logging)
    {
        super(logging);

        clearColor = SDL_FColor(0.0f, 0.0f, 0.0f, 1.0f);
    }

    void gpu(SdlGPUDevice newGPU)
    {
        assert(newGPU);
        _gpu = newGPU;
    }

    bool startRenderPass(Window window)
    {
        if (state != GPUGraphicState.none)
        {
            return false;
        }

        lastCmdBuff = SDL_AcquireGPUCommandBuffer(_gpu.getObject);
        if (!lastCmdBuff)
        {
            return false;
        }

        //TODO unsafe cast
        SDL_Window* winPtr = cast(SDL_Window*) window.rawPtr;

        if (!winPtr)
        {
            submitCmdBuffer;
            return false;
        }

        //not SDL_AcquireGPUSwapchainTexture
        if (!SDL_WaitAndAcquireGPUSwapchainTexture(lastCmdBuff, winPtr, &lastSwapchain, null, null))
        {
            submitCmdBuffer;
            return false;
        }

        if (!lastSwapchain)
        {
            submitCmdBuffer;
            return false;
        }

        SDL_GPUColorTargetInfo colorTargetInfo;
        colorTargetInfo.texture = lastSwapchain;
        colorTargetInfo.clear_color = clearColor;
        colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
        colorTargetInfo.store_op = SDL_GPU_STOREOP_STORE;

        lastPass = SDL_BeginGPURenderPass(lastCmdBuff, &colorTargetInfo, 1, null);
        if (!lastPass)
        {
            submitCmdBuffer;
            return false;
        }

        state = GPUGraphicState.renderStart;

        return true;
    }

    bool endRenderPass()
    {
        if (state != GPUGraphicState.renderStart)
        {
            return false;
        }

        state = GPUGraphicState.none;

        if (!lastPass || !lastCmdBuff)
        {
            return false;
        }

        SDL_EndGPURenderPass(lastPass);

        bool isSubmit = submitCmdBuffer;

        resetRenderer;

        return isSubmit;
    }

    bool startCopyPass()
    {
        if (state != GPUGraphicState.none)
        {
            return false;
        }

        lastCmdBuff = SDL_AcquireGPUCommandBuffer(_gpu.getObject);
        if (!lastCmdBuff)
        {
            return false;
        }

        lastCopyPass = SDL_BeginGPUCopyPass(lastCmdBuff);
        if (!lastCopyPass)
        {
            submitCmdBuffer;
            return false;
        }

        state = GPUGraphicState.copyStart;

        return true;
    }

    bool endCopyPass()
    {
        if (state != GPUGraphicState.copyStart || !lastCopyPass)
        {
            return false;
        }

        state = GPUGraphicState.none;

        SDL_EndGPUCopyPass(lastCopyPass);

        bool isSubmit = submitCmdBuffer;

        resetRenderer;

        return isSubmit;
    }

    bool uploadCopyGPUBuffer(SDL_GPUTransferBuffer* transferBufferSrc, SDL_GPUBuffer* vertexBufferDst, uint bufferRegionSizeof, uint transferOffset = 0, uint regionOffset = 0, bool isCycle = true)
    {
        if (!startCopyPass)
        {
            return false;
        }
        if (!uploadGPUBuffer(transferBufferSrc, vertexBufferDst, bufferRegionSizeof, transferOffset, regionOffset, isCycle))
        {
            return false;
        }

        return endCopyPass;
    }

    bool uploadGPUBuffer(SDL_GPUTransferBuffer* transferBufferSrc, SDL_GPUBuffer* vertexBufferDst, uint bufferDstRegionSizeof, uint transferOffset = 0, uint regionOffset = 0, bool isCycle = true)
    {
        assert(state == GPUGraphicState.copyStart);

        SDL_GPUTransferBufferLocation location;
        location.transfer_buffer = transferBufferSrc;
        location.offset = transferOffset;

        SDL_GPUBufferRegion region;
        region.buffer = vertexBufferDst;
        region.size = bufferDstRegionSizeof;
        region.offset = regionOffset;

        SDL_UnmapGPUTransferBuffer(_gpu.getObject, transferBufferSrc);

        SDL_UploadToGPUBuffer(lastCopyPass, &location, &region, isCycle);
        return true;
    }

    void uploadToTexture(SDL_GPUTextureTransferInfo* source, SDL_GPUTextureRegion* destination, bool isCycle = true)
    {
        assert(state == GPUGraphicState.copyStart);
        assert(lastCopyPass);
        SDL_UploadToGPUTexture(lastCopyPass, source, destination, isCycle);
    }

    bool submitCmdBuffer()
    {
        if (!lastCmdBuff)
        {
            return false;
        }

        return SDL_SubmitGPUCommandBuffer(lastCmdBuff);
    }

    void resetRenderer()
    {
        lastCmdBuff = null;
        lastPass = null;
        lastSwapchain = null;
        lastCopyPass = null;
    }

    bool bindPipeline(SdlGPUPipeline pipeline)
    {
        if (!lastPass)
        {
            return false;
        }

        SDL_BindGPUGraphicsPipeline(lastPass, pipeline.getObject);
        return true;
    }

    void bindVertexBuffer(uint firstSlot, SDL_GPUBufferBinding[] bindings)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastPass);
        SDL_BindGPUVertexBuffers(lastPass, firstSlot, bindings.ptr, cast(uint) bindings.length);
    }

    void bindStaticVertexBuffer(uint firstSlot, SDL_GPUBuffer* vertexBuffer, uint offset = 0)
    {
        static SDL_GPUBufferBinding[1] bufferBindings;
        bufferBindings[0].buffer = vertexBuffer;
        bufferBindings[0].offset = offset;

        bindVertexBuffer(firstSlot, bufferBindings);
    }

    bool draw(uint numVertices = 1, uint numInstances = 1, uint firstVertex = 0, uint firstInstance = 0)
    {
        if (!lastPass)
        {
            return false;
        }

        SDL_DrawGPUPrimitives(
            lastPass,
            numVertices,
            numInstances,
            firstVertex,
            firstInstance);
        return true;
    }

    void pushUniformFragmentData(uint slotIndex, void* data, uint length)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastCmdBuff);
        SDL_PushGPUFragmentUniformData(lastCmdBuff, slotIndex, data, length);
    }

    SDL_GPUColorTargetDescription[1] defaultColorTarget(Window window)
    {
        auto format = window.swapchainTextureFormat;

        SDL_GPUColorTargetDescription[1] desc = [
            SDL_GPUColorTargetDescription(format)
        ];

        return desc;
    }
}
