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
        shader.disposeWithGpu(ptr);
    }

    SDL_GPUBuffer* newGPUBufferVertex(uint size) => newGPUBuffer(SDL_GPU_BUFFERUSAGE_VERTEX, size);
    SDL_GPUBuffer* newGPUBufferIndex(uint size) => newGPUBuffer(SDL_GPU_BUFFERUSAGE_INDEX, size);
    SDL_GPUBuffer* newGPUBufferIndirect(uint size) => newGPUBuffer(
        SDL_GPU_BUFFERUSAGE_INDIRECT, size);
    //for STORAGE flag, the data in the buffer must respect std140 layout conventions. vec3 and vec4 fields are 16-byte aligned.
    SDL_GPUBuffer* newGPUBufferGraphicsStorageRead(uint size) => newGPUBuffer(
        SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ, size);
    SDL_GPUBuffer* newGPUBufferComputeStorageRead(uint size) => newGPUBuffer(
        SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ, size);
    SDL_GPUBuffer* newGPUBufferComputeStorageWrite(uint size) => newGPUBuffer(
        SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE, size);
    SDL_GPUBuffer* newGPUBufferComputeStorageReadWrite(uint size) => newGPUBuffer(
        SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ | SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE, size);

    SDL_GPUBuffer* newGPUBuffer(SDL_GPUBufferUsageFlags usageFlag, uint size)
    {
        SDL_GPUBufferCreateInfo createInfo;
        createInfo.usage = usageFlag;
        createInfo.size = size;

        SDL_GPUBuffer* newPtr = SDL_CreateGPUBuffer(ptr, &createInfo);
        if (!newPtr)
        {
            throw new Exception("New GPU buffer is null");
        }
        return newPtr;
    }

    SDL_GPUTransferBuffer* newTransferUploadBuffer(uint size) => newTransferBuffer(
        SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD, size);
    SDL_GPUTransferBuffer* newTransferDownloadBuffer(uint size) => newTransferBuffer(
        SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD, size);

    SDL_GPUTransferBuffer* newTransferBuffer(SDL_GPUTransferBufferUsage usage, uint size)
    {
        assert(ptr);

        SDL_GPUTransferBufferCreateInfo info;
        info.usage = usage;
        info.size = size;

        SDL_GPUTransferBuffer* buffPtr = SDL_CreateGPUTransferBuffer(ptr, &info);
        if (!buffPtr)
        {
            throw new Exception("Transfer buffer is null");
        }
        return buffPtr;
    }

    void deleteTransferBuffer(SDL_GPUTransferBuffer* buffPtr)
    {
        SDL_ReleaseGPUTransferBuffer(ptr, buffPtr);
    }

    void* mapTransferBuffer(SDL_GPUTransferBuffer* transferBuffer, bool cycle = true)
    {
        assert(ptr);
        void* addrPtr = SDL_MapGPUTransferBuffer(ptr, transferBuffer, cycle);
        if (!addrPtr)
        {
            throw new Exception("Mapped buffer address is null");
        }
        return addrPtr;
    }

    void uploadToGPUBuffer(SDL_GPUCopyPass* copyPass, SDL_GPUTransferBufferLocation* source, SDL_GPUBufferRegion* dest, bool cycle = true)
    {
        SDL_UploadToGPUBuffer(copyPass, source, dest, cycle);
    }

    void uploadToGPUTexture(SDL_GPUCopyPass* copyPass, SDL_GPUTextureTransferInfo* source, SDL_GPUTextureRegion* dest, bool cycle = true)
    {
        SDL_UploadToGPUTexture(copyPass, source, dest, cycle);
    }

    void unmapTransferBuffer(SDL_GPUTransferBuffer* transferBuffer)
    {
        SDL_UnmapGPUTransferBuffer(ptr, transferBuffer);
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
