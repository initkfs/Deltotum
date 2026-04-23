module api.dm.kit.graphics.gpu.gpu_graphic;

import api.core.loggers.logging : Logging;
import api.dm.kit.windows.window : Window;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.utils.types : ProviderFactory;

import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;

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
        SDL_GPUSampler* _defaultMipMapSampler;

        TextureGPU _defaultDiffuse;
        TextureGPU _defaultSpecular;
        TextureGPU _defaultNormal;
        TextureGPU _defaultAO;
        TextureGPU _defaultEmission;
        TextureGPU _defaultDisp;
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

    bool startRenderPass(SDL_GPUColorTargetInfo[] colorTargets, SDL_GPUDepthStencilTargetInfo* depthInfo = null, bool isAcquireSwapchain = true) => dev
        .startRenderPass(colorTargets, depthInfo, isAcquireSwapchain, currSdlWindow);

    bool startCmdBuffer(SDL_GPUDepthStencilTargetInfo* stencilInfo = null, bool isAcquireSwapchain = true)
    {
        return dev.startCmdBuffer(stencilInfo, isAcquireSwapchain, currSdlWindow);
    }

    bool beginRenderPass(SDL_GPUColorTargetInfo[] colorTargets, SDL_GPUDepthStencilTargetInfo* stencilInfo = null)
    {
        return dev.beginRenderPass(colorTargets, stencilInfo);
    }

    SdlGPUPipeline newPipeline(
        string vertexPath,
        string fragmentPath,
        ComPipelineBuffers pipeBuffers,
        SDL_GPUGraphicsPipelineTargetInfo* targetInfo = null,
        SDL_GPURasterizerState* rasterState = null,
        SDL_GPUDepthStencilState* stencilState = null,
        string name = null,
        scope void delegate(
            ref SDL_GPUGraphicsPipelineCreateInfo) onPipeSettings = null,
        bool isUseDefaultSampling = true,
        bool isUseVertex = true
    )
    {
        return dev.newPipeline(vertexPath, fragmentPath, pipeBuffers, targetInfo, rasterState, stencilState, name, onPipeSettings, isUseDefaultSampling, isUseVertex);
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

    SDL_GPUColorTargetInfo[1] defaultColorTarget()
    {
        SDL_GPUColorTargetInfo target;
        target.clear_color = clearColor;
        target.load_op = SDL_GPU_LOADOP_CLEAR;
        target.store_op = SDL_GPU_STOREOP_STORE;

        SDL_GPUColorTargetInfo[1] targets;
        targets[0] = target;

        return targets;
    }

    SDL_GPUColorTargetInfo[1] defaultSwapchainTarget()
    {
        auto targets = defaultColorTarget;
        if (targets.length > 0)
        {
            targets[0].texture = dev.swapchain;
        }
        return targets;
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

    void defaultDisp(TextureGPU tex)
    {
        _defaultDisp = tex;
    }

    TextureGPU defaultDisp()
    {
        assert(_defaultDisp);
        return _defaultDisp;
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

    SDL_GPUSampler* defaultMipMapSampler()
    {
        assert(_defaultMipMapSampler);
        return _defaultMipMapSampler;
    }

    void defaultMipMapSampler(SDL_GPUSampler* sampler)
    {
        assert(sampler);
        _defaultMipMapSampler = sampler;
    }

    override void dispose()
    {
        super.dispose;

        if (_defaultSampler)
        {
            dev.deleteSampler(_defaultSampler);
        }
    }

}
