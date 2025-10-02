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

struct ComVertex
{
    float x = 0, y = 0, z = 0; //vec3 position
    float r = 0, g = 0, b = 0, a = 1.0; //vec4 color
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

    protected ubyte[] readShader(string path)
    {
        import std.file : read;

        auto vertexText = cast(ubyte[]) path.read;
        return vertexText;
    }

    SdlGPUShader newVertexSPIRV(
        string path,
        uint numSamples = 0,
        uint numStorageBuffers = 0,
        uint numUniformBuffers = 0,
        uint numStorageTextures = 0,
    )
    {
        ubyte[] code = readShader(path);
        return newVertexSPIRV(code, numSamples, numStorageBuffers, numUniformBuffers, numStorageTextures);
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

    SDL_GPUVertexAttribute vertexAttribute(uint location, uint bufferSlot, SDL_GPUVertexElementFormat format, uint offset = 0)
    {
        SDL_GPUVertexAttribute attr;
        attr.location = location;
        attr.buffer_slot = bufferSlot;
        attr.format = format;
        attr.offset = offset;
        return attr;
    }

    SdlGPUShader newFragmentSPIRV(
        string path,
        uint numSamples = 0,
        uint numStorageBuffers = 0,
        uint numUniformBuffers = 0,
        uint numStorageTextures = 0,
    )
    {
        ubyte[] code = readShader(path);
        return newFragmentSPIRV(code, numSamples, numStorageBuffers, numUniformBuffers, numStorageTextures);
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

    import api.dm.kit.windows.window : Window;

    SdlGPUPipeline newPipeline(Window window,
        string vertexPath,
        string fragmentPath,
        uint numVertexSamples = 0,
        uint numVertexStorageBuffers = 0,
        uint numVertexUniformBuffers = 0,
        uint numVertexStorageTextures = 0,
        uint numFragSamples = 0,
        uint numFragStorageBuffers = 0,
        uint numFragUniformBuffers = 0,
        uint numFragStorageTextures = 0
    )
    {
        auto vertexShader = newVertexSPIRV(vertexPath, numVertexSamples, numVertexStorageBuffers, numVertexUniformBuffers, numVertexStorageTextures);

        auto fragmentShader = newFragmentSPIRV(fragmentPath, numFragSamples, numFragStorageBuffers, numFragUniformBuffers, numFragStorageTextures);

        auto pipeline = newVertexPipeline(window, vertexShader, fragmentShader);

        deleteShader(vertexShader);
        deleteShader(fragmentShader);

        return pipeline;
    }

    SdlGPUPipeline newVertexPipeline(Window window, SdlGPUShader vertexShader, SdlGPUShader fragmentShader)
    {
        SDL_GPUGraphicsPipelineCreateInfo info;

        info.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;
        info.vertex_shader = vertexShader.getObject;
        info.fragment_shader = fragmentShader.getObject;

        SDL_GPUVertexBufferDescription[1] vertexBufferDesctiptions = comVertexDesc;
        info.vertex_input_state.num_vertex_buffers = vertexBufferDesctiptions.length;
        info.vertex_input_state.vertex_buffer_descriptions = vertexBufferDesctiptions.ptr;

        SDL_GPUVertexAttribute[2] vertexAttributes = comVertexAttrs;

        info.vertex_input_state.num_vertex_attributes = vertexAttributes.length;
        info.vertex_input_state.vertex_attributes = vertexAttributes.ptr;

        SDL_GPUColorTargetDescription[1] colorTargetDescriptions = blendingAlpha(window);
        info.target_info.num_color_targets = colorTargetDescriptions.length;
        info.target_info.color_target_descriptions = colorTargetDescriptions.ptr;

        auto pipeline = newPipeline(info);
        return pipeline;
    }

    SDL_GPUColorTargetDescription[1] blendingAlpha(Window window)
    {
        SDL_GPUColorTargetDescription[1] colorTargetDescriptions;

        colorTargetDescriptions[0] = SDL_GPUColorTargetDescription();

        colorTargetDescriptions[0].blend_state.enable_blend = true;
        colorTargetDescriptions[0].blend_state.color_blend_op = SDL_GPU_BLENDOP_ADD;
        colorTargetDescriptions[0].blend_state.alpha_blend_op = SDL_GPU_BLENDOP_ADD;
        colorTargetDescriptions[0].blend_state.src_color_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA;
        colorTargetDescriptions[0].blend_state.dst_color_blendfactor = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        colorTargetDescriptions[0].blend_state.src_alpha_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA;
        colorTargetDescriptions[0].blend_state.dst_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        colorTargetDescriptions[0].format = window.swapchainTextureFormat;

        return colorTargetDescriptions;
    }

    void deletePipeline(SdlGPUPipeline pipe)
    {
        assert(ptr);
        SDL_ReleaseGPUGraphicsPipeline(ptr, pipe.getObject);
        pipe.setNull;
    }

    void deleteShader(SdlGPUShader shader)
    {
        assert(ptr);
        shader.disposeWithGpu(ptr);
        shader.setNull;
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

    void deleteGPUBuffer(SDL_GPUBuffer* buffPtr)
    {
        SDL_ReleaseGPUBuffer(ptr, buffPtr);
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

    void copyToNewGPUBuffer(ComVertex[] verts, bool isCycle = true, out SDL_GPUBuffer* vertexBuffer, out SDL_GPUTransferBuffer* transferBuffer)
    {
        uint len = cast(uint)(verts.length * ComVertex.sizeof);
        vertexBuffer = newGPUBufferVertex(len);
        transferBuffer = newTransferUploadBuffer(len);

        ComVertex[] data = (cast(ComVertex*) mapTransferBuffer(transferBuffer, isCycle))[0 .. (
                verts.length)];

        data[0 .. verts.length] = verts[];
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

    bool isSupportTexture(SDL_GPUTextureFormat format, SDL_GPUTextureType type, SDL_GPUTextureUsageFlags usage)
    {
        return SDL_GPUTextureSupportsFormat(ptr, format, type, usage);
    }

    /** 
     *SDL_GPU_SAMPLECOUNT_1, No multisampling.
     SDL_GPU_SAMPLECOUNT_2, MSAA 2x 
     SDL_GPU_SAMPLECOUNT_4,  MSAA 4x
     SDL_GPU_SAMPLECOUNT_8   MSAA 8x
     */
    SDL_GPUTexture* newGTexture(SDL_GPUTextureType type, SDL_GPUTextureFormat format, SDL_GPUTextureUsageFlags usage, uint width, uint height, uint layerCountOrDepth, uint numLevels = 1, SDL_GPUSampleCount sampleCount = SDL_GPU_SAMPLECOUNT_1)
    {
        SDL_GPUTextureCreateInfo info;
        info.type = type;

        //R8G8B8A8_UNORM (R-G-B-A),  B8G8R8A8_UNORM (B-G-R-A), _SRGB for PNG\JPEG
        info.format = format;
        info.usage = usage;
        info.width = width;
        info.height = height;
        info.layer_count_or_depth = layerCountOrDepth;
        info.num_levels = numLevels;
        info.sample_count = sampleCount;
        info.props = 0;

        return newTexture(&info);
    }

    SDL_GPUTexture* newTexture(SDL_GPUTextureCreateInfo* info)
    {
        auto textPtr = SDL_CreateGPUTexture(ptr, info);
        if (!textPtr)
        {
            throw new Exception("Texture is null: " ~ getError);
        }
        return textPtr;
    }

    void deleteTexture(SDL_GPUTexture* tPtr)
    {
        SDL_ReleaseGPUTexture(ptr, tPtr);
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

    SDL_GPUTextureFormat getSwapchainTextureFormat(ComWindow comWindow)
    {
        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr winNat;
        if (const err = comWindow.nativePtr(winNat))
        {
            return SDL_GPU_TEXTUREFORMAT_INVALID;
        }

        auto sdlWinPtr = winNat.castSafe!(SDL_Window*);

        return SDL_GetGPUSwapchainTextureFormat(ptr, sdlWinPtr);
    }

    SDL_GPUVertexBufferDescription[1] comVertexDesc()
    {
        SDL_GPUVertexBufferDescription[1] vertexBufferDesctiptions;
        vertexBufferDesctiptions[0].slot = 0;
        vertexBufferDesctiptions[0].input_rate = SDL_GPU_VERTEXINPUTRATE_VERTEX;
        vertexBufferDesctiptions[0].instance_step_rate = 0;
        vertexBufferDesctiptions[0].pitch = ComVertex.sizeof;

        return vertexBufferDesctiptions;
    }

    SDL_GPUVertexAttribute[2] comVertexAttrs()
    {
        SDL_GPUVertexAttribute[2] vertexAttributes;

        //position
        vertexAttributes[0].buffer_slot = 0;
        vertexAttributes[0].location = 0; //location = 0 in shader
        vertexAttributes[0].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3; //vec3
        vertexAttributes[0].offset = 0; // start from the first byte from current buffer position

        // color
        vertexAttributes[1].buffer_slot = 0;
        vertexAttributes[1].location = 1; // layout (location = 1) in shader
        vertexAttributes[1].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4; //vec4
        vertexAttributes[1].offset = float.sizeof * 3; // 4th float from current buffer position

        return vertexAttributes;
    }

}
