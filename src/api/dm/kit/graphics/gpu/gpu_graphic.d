module api.dm.kit.graphics.gpu.gpu_graphic;

import api.core.loggers.logging : Logging;
import api.dm.kit.windows.window : Window;

import api.core.components.units.services.loggable_unit : LoggableUnit;
import api.core.utils.factories : ProviderFactory;

//TODO extract COM interfaces
import api.dm.back.sdl3.externs.csdl3;
import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

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
    }

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
        lastCmdBuff = SDL_AcquireGPUCommandBuffer(_gpu.getObject);
        if (!lastCmdBuff)
        {
            return false;
        }

        //TODO unsafe cast
        SDL_Window* winPtr = cast(SDL_Window*) window.rawPtr;

        if (!lastCmdBuff && !winPtr)
        {
            return false;
        }

        if (!SDL_WaitAndAcquireGPUSwapchainTexture(lastCmdBuff, winPtr, &lastSwapchain, null, null))
        {
            return false;
        }

        if (!lastSwapchain)
        {
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
            return false;
        }

        return true;
    }

    bool endRenderPass()
    {
        if (!lastPass || !lastCmdBuff)
        {
            return false;
        }

        SDL_EndGPURenderPass(lastPass);

        SDL_SubmitGPUCommandBuffer(lastCmdBuff);

        resetRenderer;

        return true;
    }

    void resetRenderer()
    {
        lastCmdBuff = null;
        lastPass = null;
        lastSwapchain = null;
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
}
