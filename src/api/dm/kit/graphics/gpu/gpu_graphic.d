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
        SDL_FColor clearColor;

        Window _currentWindow;
        SDL_Window* currSdlWindow;

        SdlGPUDevice device;
    }

    bool isActive() => device.isCreated;
    SdlGPUDevice dev() => device;

    this( Logging logging, SdlGPUDevice device, Window window)
    {
        super(logging);
        assert(device);
        assert(window);

        clearColor = SDL_FColor(0.0f, 0.0f, 0.0f, 1.0f);

        assert(window);
        _currentWindow = window;

        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr winNatPtr;
        if (!window.nativePtr(winNatPtr))
        {
            throw new Exception("Native window pointer is null");
        }

        currSdlWindow = winNatPtr.castSafe!(SDL_Window*);

        this.device = device;
    }

    bool startRenderPass() => dev.startRenderPass(currSdlWindow, clearColor);
    bool startRenderPass(SDL_GPUColorTargetInfo[] colorTargets) => dev.startRenderPass(
        colorTargets, currSdlWindow);
    bool startRenderPass(SDL_GPUDepthStencilTargetInfo* depthInfo) => dev.startRenderPass(
    currSdlWindow, clearColor, depthInfo);

    SdlGPUPipeline newPipeline(
        string vertexPath,
        string fragmentPath,
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
        return dev.newPipeline(currSdlWindow, vertexPath, fragmentPath, numVertexSamples, numVertexStorageBuffers, numVertexUniformBuffers, numVertexStorageTextures, numFragSamples, numFragStorageBuffers, numFragUniformBuffers, numFragStorageTextures, rasterState, stencilState, colorDesc);
    }

    SDL_GPUTextureFormat getSwapchainTextureFormat() => dev.getSwapchainTextureFormat(currSdlWindow);

}
