module api.dm.back.sdl3.gpu.sdl_gpu_device;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphic.com_window : ComWindow;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;

import api.dm.back.sdl3.gpu.sdl_gpu_shader : SdlGPUShader;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

import std.string : toStringz, fromStringz;

import api.dm.back.sdl3.externs.csdl3;

alias ComShaderFormat = SDL_GPUShaderFormat;

enum ComGPUDriver : string
{
    any = null,
    vulkan = "vulkan",
    direct3d12 = "direct3d12",
    metal = "metal"
}

enum ComShaderType
{
    vertex,
    fragment
}

struct GPUPipelineData
{
    SDL_GPUShader* vertex_shader;
    SDL_GPUShader* fragment_shader;
    SDL_GPUVertexInputState vertex_input_state;
    SDL_GPUPrimitiveType primitive_type;
    SDL_GPURasterizerState rasterizer_state;
    SDL_GPUMultisampleState multisample_state;
    SDL_GPUDepthStencilState depth_stencil_state;
    SDL_GPUGraphicsPipelineTargetInfo target_info;

    SDL_PropertiesID props;
}

class SdlGPUDevice : SdlObjectWrapper!SDL_GPUDevice
{
    protected
    {
        string driverName;

        string entryPointName = "main";
    }

    this()
    {

    }

    this(SDL_GPUDevice* newPtr)
    {
        super(newPtr);
    }

    ComResult create(ComShaderFormat foramtFlags = SDL_GPU_SHADERFORMAT_SPIRV, bool isDebugMode = false, string driverName = ComGPUDriver
            .any)
    {
        this.driverName = driverName;

        ptr = SDL_CreateGPUDevice(
            foramtFlags,
            isDebugMode,
            driverName.length > 0 ? driverName.toStringz : null);
        if (!ptr)
        {
            return getErrorRes("GPU device not created");
        }
        return ComResult.success;
    }

    SdlGPUShader newVertexSPIRV(
        ubyte[] code,
        uint numSamples = 0,
        uint numStorageBuffers = 0,
        uint numUniformBuffers = 0,
        uint numStorageTextures = 0,
    )
    {
        return newSPIRV(code, ComShaderType.vertex, numSamples, numStorageBuffers, numUniformBuffers, numStorageTextures);
    }

    SdlGPUShader newFragmentSPIRV(
        ubyte[] code,
        uint numSamples = 0,
        uint numStorageBuffers = 0,
        uint numUniformBuffers = 0,
        uint numStorageTextures = 0,
    )
    {
        return newSPIRV(code, ComShaderType.fragment, numSamples, numStorageBuffers, numUniformBuffers, numStorageTextures);
    }

    SdlGPUShader newSPIRV(
        ubyte[] code,
        ComShaderType type = ComShaderType.vertex,
        uint numSamples = 0,
        uint numStorageBuffers = 0,
        uint numUniformBuffers = 0,
        uint numStorageTextures = 0,
    )
    {
        assert(ptr);
        SDL_GPUShaderCreateInfo shaderInfo;
        shaderInfo.props = 0;
        shaderInfo.format = SDL_GPU_SHADERFORMAT_SPIRV;

        SDL_GPUShaderStage stage;
        final switch (type) with (ComShaderType)
        {
            case vertex:
                stage = SDL_GPUShaderStage.SDL_GPU_SHADERSTAGE_VERTEX;
                break;
            case fragment:
                stage = SDL_GPUShaderStage.SDL_GPU_SHADERSTAGE_FRAGMENT;
                break;
        }

        shaderInfo.stage = stage;

        assert(entryPointName);

        import std.utf : toUTFz;

        shaderInfo.entrypoint = entryPointName.toUTFz!(const(char*));

        import std.string : toStringz;

        shaderInfo.code = cast(const(ubyte*)) code.ptr;
        shaderInfo.code_size = code.length;

        shaderInfo.num_samplers = numSamples;
        shaderInfo.num_uniform_buffers = numUniformBuffers;
        shaderInfo.num_storage_buffers = numStorageBuffers;
        shaderInfo.num_storage_textures = numStorageTextures;

        auto shaderPtr = SDL_CreateGPUShader(ptr, &shaderInfo);
        if (!shaderPtr)
        {
            throw new Exception(getError);
        }

        return new SdlGPUShader(shaderPtr);
    }

    SdlGPUPipeline newPipeline(SDL_GPUGraphicsPipelineCreateInfo info)
    {
        assert(ptr);
        auto pipePtr = SDL_CreateGPUGraphicsPipeline(ptr, &info);
        if (!pipePtr)
        {
            throw new Exception("GPU pipeline is null: " ~ getError);
        }

        return new SdlGPUPipeline(pipePtr);
    }

    void deletePipeline(SdlGPUPipeline pipe)
    {
        assert(ptr);
        SDL_ReleaseGPUGraphicsPipeline(ptr, pipe.getObject);
    }

    void deleteShader(SdlGPUShader shader)
    {
        assert(ptr);
        SDL_ReleaseGPUShader(ptr, shader.getObject);
    }

    string getLastErrorStr() => getError;

    override protected bool disposePtr() nothrow
    {
        if (ptr)
        {
            SDL_DestroyGPUDevice(ptr);
            return true;
        }
        return false;
    }

    ComResult getDriverNameNew(out string name)
    {
        assert(ptr);
        const char* namePtr = SDL_GetGPUDeviceDriver(ptr);
        if (!namePtr)
        {
            return getErrorRes("GPU driver name is null");
        }
        name = namePtr.fromStringz.idup;
        return ComResult.success;
    }

    //This must be called before SDL_AcquireGPUSwapchainTexture is called using the window. 
    ComResult attachToWindow(ComWindow window)
    {
        assert(window);
        assert(ptr);

        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr natWinPtr;
        if (const err = window.nativePtr(natWinPtr))
        {
            return err;
        }

        SDL_Window* sdlWinPtr = natWinPtr.castSafe!(SDL_Window*);

        return attachToWindow(sdlWinPtr);
    }

    ComResult attachToWindow(SDL_Window* sdlWinPtr)
    {
        assert(sdlWinPtr);
        assert(ptr);

        if (!SDL_ClaimWindowForGPUDevice(ptr, sdlWinPtr))
        {
            return getErrorRes("Error window for GPU");
        }

        return ComResult.success;
    }

    ComResult releaseFromWindow(ComWindow window)
    {
        assert(window);
        assert(ptr);

        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr natWinPtr;
        if (const err = window.nativePtr(natWinPtr))
        {
            return err;
        }

        SDL_Window* sdlWinPtr = natWinPtr.castSafe!(SDL_Window*);

        return releaseFromWindow(sdlWinPtr);
    }

    ComResult releaseFromWindow(SDL_Window* sdlWinPtr)
    {
        assert(sdlWinPtr);
        assert(ptr);

        SDL_ReleaseWindowFromGPUDevice(ptr, sdlWinPtr);

        return ComResult.success;
    }

}
