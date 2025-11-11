module api.dm.kit.graphics.gpu.gpu_graphic;

import api.core.loggers.logging : Logging;
import api.dm.kit.windows.window : Window;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.utils.factories : ProviderFactory;

//TODO extract COM interfaces
import api.dm.back.sdl3.externs.csdl3;
import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.com.gpu.com_3d_types : ComVertex;

/**
 * Authors: initkfs
 */
class GPUGraphic : ApplicationUnit
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

    this(Logging logging, Config config, Context context, SdlGPUDevice device, Window window)
    {
        super(logging, config, context);
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
        SDL_GPUGraphicsPipelineTargetInfo* colorDesc = null,
        string name = null
    )
    {
        return dev.newPipeline(currSdlWindow, vertexPath, fragmentPath, numVertexSamples, numVertexStorageBuffers, numVertexUniformBuffers, numVertexStorageTextures, numFragSamples, numFragStorageBuffers, numFragUniformBuffers, numFragStorageTextures, rasterState, stencilState, colorDesc, name);
    }

    SDL_GPUTextureFormat getSwapchainTextureFormat() => dev.getSwapchainTextureFormat(
        currSdlWindow);

    string shaderDefaultPath(string fileNameWithoutExt, string shadersDirName = "shaders")
    {
        import std.path : buildPath;
        import std.file : exists, isFile;

        assert(fileNameWithoutExt.length > 0);
        assert(shadersDirName.length > 0);
        //TODO other shaders
        string shaderExt = ".spv";
        if (fileNameWithoutExt[$ - 1] == '.')
        {
            shaderExt = shaderExt[1 .. $];
        }

        immutable path = buildPath(context.app.dataDir, shadersDirName, fileNameWithoutExt ~ shaderExt);
        if (!path.exists || !path.isFile)
        {
            throw new Exception("Shader file doesn't exist or not a file: " ~ path);
        }

        return path;
    }

}
