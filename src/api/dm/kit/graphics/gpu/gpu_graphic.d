module api.dm.kit.graphics.gpu.gpu_graphic;

import api.core.loggers.logging : Logging;
import api.dm.kit.windows.window : Window;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.utils.types : ProviderFactory;

//TODO extract COM interfaces
import api.dm.back.sdl3.externs.csdl3;
import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

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

    protected
    {
        SDL_GPUSampler* _defaultSampler;
        TextureGPU _defaultDiffuse;
        TextureGPU _defaultSpecular;
        TextureGPU _defaultNormal;
        TextureGPU _defaultAO;
        TextureGPU _defaultEmission;
    }

    SdlGPUDevice dev() => device;

    this(Logging logging, Config config, Context context, SdlGPUDevice device, Window window)
    {
        super(logging, config, context);
        assert(device);
        assert(window);

        clearColor = SDL_FColor(0.0f, 0.0f, 0.0f, 1.0f);

        assert(window);
        _currentWindow = window;

        import api.dm.com.ptrs.com_native_ptr : ComNativePtr;

        ComNativePtr winNatPtr = window.nativePtr;
        currSdlWindow = winNatPtr.castSafe!(SDL_Window*);

        this.device = device;
    }

    bool startRenderPass(SDL_GPUColorTargetInfo[] colorTargets, SDL_GPUDepthStencilTargetInfo* depthInfo, bool isAcquireSwapchain = true) => dev
        .startRenderPass(colorTargets, currSdlWindow, depthInfo, isAcquireSwapchain);
    bool startRenderPass(bool isAcquireSwapchain = true) => dev.startRenderPass(
        currSdlWindow, clearColor, null, isAcquireSwapchain);
    bool startRenderPass(SDL_GPUColorTargetInfo[] colorTargets, bool isAcquireSwapchain = true) => dev
        .startRenderPass(
            colorTargets, currSdlWindow, null, isAcquireSwapchain);
    bool startRenderPass(SDL_GPUDepthStencilTargetInfo* depthInfo, bool isAcquireSwapchain = true) => dev
        .startRenderPass(
            currSdlWindow, clearColor, depthInfo, isAcquireSwapchain);

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
        string name = null,
        bool isUseDefaultSampling = true,
        bool isUseVertex = true
    )
    {
        return dev.newPipeline(currSdlWindow, vertexPath, fragmentPath, numVertexSamples, numVertexStorageBuffers, numVertexUniformBuffers, numVertexStorageTextures, numFragSamples, numFragStorageBuffers, numFragUniformBuffers, numFragStorageTextures, rasterState, stencilState, colorDesc, name, isUseDefaultSampling, isUseVertex);
    }

    SDL_GPUTextureFormat getSwapchainTextureFormat() => dev.getSwapchainTextureFormat(
        currSdlWindow);

    string shaderDefaultPath(string fileNameWithoutExt, string shadersDirName = "shaders", string shaderCompiledDirName = "out", string shaderType = "spirv")
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

        immutable path = buildPath(context.app.dataDir, shadersDirName, shaderCompiledDirName, shaderType, fileNameWithoutExt ~ shaderExt);
        if (!path.exists || !path.isFile)
        {
            throw new Exception("Shader file doesn't exist or not a file: " ~ path);
        }

        return path;
    }

    void defaultDiffuse(TextureGPU tex)
    {
        _defaultDiffuse = tex;
    }

    TextureGPU defaultDiffuse()
    {
        assert(_defaultDiffuse);
        return _defaultDiffuse;
    }

    void defaultSpecular(TextureGPU tex)
    {
        _defaultSpecular = tex;
    }

    TextureGPU defaultSpecular()
    {
        assert(_defaultSpecular);
        return _defaultSpecular;
    }

    void defaultNormal(TextureGPU tex)
    {
        _defaultNormal = tex;
    }

    TextureGPU defaultNormal()
    {
        assert(_defaultNormal);
        return _defaultNormal;
    }

    void defaultAO(TextureGPU tex)
    {
        _defaultAO = tex;
    }

    TextureGPU defaultAO()
    {
        assert(_defaultAO);
        return _defaultAO;
    }

    void defaultEmission(TextureGPU tex)
    {
        _defaultEmission = tex;
    }

    TextureGPU defaultEmission()
    {
        assert(_defaultEmission);
        return _defaultEmission;
    }

    SDL_GPUSampler* defaultSampler()
    {
        assert(_defaultSampler);
        return _defaultSampler;
    }

    void defaultSampler(SDL_GPUSampler* sampler)
    {
        assert(sampler);
        _defaultSampler = sampler;
    }

    override void dispose()
    {
        super.dispose;

        if (_defaultSampler)
        {
            dev.removeSampler(_defaultSampler);
        }
    }

}
