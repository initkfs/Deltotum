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
    //float r = 0, g = 0, b = 0, a = 1.0; //vec4 color
    float u = 0, v = 0; //0..1
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

enum GPUGraphicState
{
    none,
    copyStart,
    renderStart
}

class SdlGPUDevice : SdlObjectWrapper!SDL_GPUDevice
{
    protected
    {
        string driverName;

        string entryPointName = "main";

        SDL_GPUCommandBuffer* lastCmdBuff;
        SDL_GPURenderPass* lastPass;
        SDL_GPUCopyPass* lastCopyPass;
        SDL_GPUTexture* lastSwapchain;

        GPUGraphicState state;
    }

    this()
    {

    }

    this(SDL_GPUDevice* newPtr)
    {
        super(newPtr);
    }

    SDL_GPUCommandBuffer* cmdBuff() => lastCmdBuff;
    SDL_GPURenderPass* renderPass() => lastPass;
    SDL_GPUCopyPass* copyPass() => lastCopyPass;
    SDL_GPUTexture* swapchain() => lastSwapchain;

    ComResult create(ComShaderFormat formatFlags = SDL_GPU_SHADERFORMAT_SPIRV, bool isDebugMode = true, string driverName = ComGPUDriver
            .any)
    {
        this.driverName = driverName;

        ptr = SDL_CreateGPUDevice(
            formatFlags,
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

    SdlGPUPipeline newPipeline(SDL_Window* window,
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

    SdlGPUPipeline newVertexPipeline(SDL_Window* window, SdlGPUShader vertexShader, SdlGPUShader fragmentShader)
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

        SDL_GPUColorTargetDescription[1] colorTargetDescriptions = colorTarget(window);
        info.target_info.num_color_targets = colorTargetDescriptions.length;
        info.target_info.color_target_descriptions = colorTargetDescriptions.ptr;

        auto pipeline = newPipeline(info);
        return pipeline;
    }

    SDL_GPUColorTargetDescription[1] colorTarget(SDL_Window* window)
    {
        SDL_GPUColorTargetDescription[1] colorTargetDescriptions;

        colorTargetDescriptions[0] = SDL_GPUColorTargetDescription();
        colorTargetDescriptions[0].format = getSwapchainTextureFormat(window);

        return colorTargetDescriptions;
    }

    SDL_GPUColorTargetDescription[1] blendingAlpha(SDL_Window* window)
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
        colorTargetDescriptions[0].format = getSwapchainTextureFormat(window);

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

    void* mapTransferBuffer(SDL_GPUTransferBuffer* transferBuffer, bool cycle = false)
    {
        assert(ptr);
        void* addrPtr = SDL_MapGPUTransferBuffer(ptr, transferBuffer, cycle);
        if (!addrPtr)
        {
            throw new Exception("Mapped buffer address is null");
        }
        return addrPtr;
    }

    void copyToBuffer(T...)(SDL_GPUTransferBuffer* transferBuffer, bool isCycle, T args)
    {
        ubyte* buffPtr = cast(ubyte*) mapTransferBuffer(transferBuffer, isCycle);
        size_t offset = 0;

        static foreach (arg; args)
        {
            {
                alias Type = typeof(arg[0]);
                Type[] buff = (cast(Type*) &buffPtr[offset])[0 .. arg.length];
                buff[0 .. arg.length] = arg;
                offset += arg.length * Type.sizeof;
            }
        }
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
    SDL_GPUTexture* newTexture(SDL_GPUTextureType type, SDL_GPUTextureFormat format, SDL_GPUTextureUsageFlags usage, uint width, uint height, uint layerCountOrDepth, uint numLevels = 1, SDL_GPUSampleCount sampleCount = SDL_GPU_SAMPLECOUNT_1)
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

    ComResult removeFromWindow(ComWindow window)
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

        return removeFromWindow(sdlWinPtr);
    }

    ComResult removeFromWindow(SDL_Window* sdlWinPtr)
    {
        assert(sdlWinPtr);
        assert(ptr);

        SDL_ReleaseWindowFromGPUDevice(ptr, sdlWinPtr);

        return ComResult.success;
    }

    SDL_GPUTextureFormat getSwapchainTextureFormat(SDL_Window* comWindow)
    {
        return SDL_GetGPUSwapchainTextureFormat(ptr, comWindow);
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

        return getSwapchainTextureFormat(sdlWinPtr);
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
        // vertexAttributes[1].buffer_slot = 0;
        // vertexAttributes[1].location = 1; // layout (location = 1) in shader
        // vertexAttributes[1].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4; //vec4
        // vertexAttributes[1].offset = float.sizeof * 3; // 4th float from current buffer position

        //uv
        vertexAttributes[1].buffer_slot = 0;
        vertexAttributes[1].location = 1; // layout (location = 2) in shader
        vertexAttributes[1].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2; //vec2
        vertexAttributes[1].offset = float.sizeof * 3; // 4th float from current buffer position

        return vertexAttributes;
    }

    bool startRenderPass(SDL_Window* currSdlWindow, SDL_FColor clearColor)
    {
        SDL_GPUColorTargetInfo[1] colorTargetInfo;
        colorTargetInfo[0].clear_color = clearColor;
        colorTargetInfo[0].load_op = SDL_GPU_LOADOP_CLEAR;
        colorTargetInfo[0].store_op = SDL_GPU_STOREOP_STORE;

        return startRenderPass(colorTargetInfo, currSdlWindow);
    }

    bool startRenderPass(SDL_GPUColorTargetInfo[] colorTargets, SDL_Window* currSdlWindow)
    {
        assert(currSdlWindow);
        assert(ptr);

        if (state != GPUGraphicState.none)
        {
            return false;
        }

        lastCmdBuff = SDL_AcquireGPUCommandBuffer(ptr);
        if (!lastCmdBuff)
        {
            return false;
        }

        //not SDL_AcquireGPUSwapchainTexture
        if (!SDL_WaitAndAcquireGPUSwapchainTexture(lastCmdBuff, currSdlWindow, &lastSwapchain, null, null))
        {
            submitCmdBuffer;
            return false;
        }

        if (!lastSwapchain)
        {
            submitCmdBuffer;
            return false;
        }

        assert(colorTargets.length > 0);
        if (!colorTargets[0].texture)
        {
            colorTargets[0].texture = lastSwapchain;
        }

        lastPass = SDL_BeginGPURenderPass(lastCmdBuff, colorTargets.ptr, cast(uint) colorTargets.length, null);
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

        resetState;

        return isSubmit;
    }

    bool startCopyPass()
    {
        assert(ptr);
        if (state != GPUGraphicState.none)
        {
            return false;
        }

        lastCmdBuff = SDL_AcquireGPUCommandBuffer(ptr);
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

        resetState;

        return isSubmit;
    }

    void unmapAndUpload(SDL_GPUTransferBuffer* transferBufferSrc, SDL_GPUBuffer* vertexBufferDst, uint bufferDstRegionSizeof, uint transferOffset = 0, uint regionOffset = 0, bool isCycle = false)
    {
        assert(state == GPUGraphicState.copyStart);
        assert(lastCopyPass);

        SDL_GPUTransferBufferLocation location;
        location.transfer_buffer = transferBufferSrc;
        location.offset = transferOffset;

        SDL_GPUBufferRegion region;
        region.buffer = vertexBufferDst;
        region.size = bufferDstRegionSizeof;
        region.offset = regionOffset;

        SDL_UnmapGPUTransferBuffer(ptr, transferBufferSrc);
        SDL_UploadToGPUBuffer(lastCopyPass, &location, &region, isCycle);
    }

    void uploadTexture(SDL_GPUTransferBuffer* sourceBuffer, SDL_GPUTexture* destTexture, uint width, uint height, uint sourceBufferOffset = 0, bool isCycle = false)
    {
        SDL_GPUTextureTransferInfo source;
        //Direct3D 12
        //pixels_per_row align 256
        //offset align 512
        source.transfer_buffer = sourceBuffer;
        source.offset = sourceBufferOffset;
        //source.pixels_per_row = 512;
        //source.rows_per_layer = 512;

        SDL_GPUTextureRegion dest;
        dest.texture = destTexture;
        dest.mip_level = 0;
        dest.x = 0;
        dest.y = 0;
        dest.z = 0;
        dest.w = width;
        dest.h = height;
        dest.d = 1;

        uploadTexture(&source, &dest, isCycle);
    }

    void uploadTexture(SDL_GPUTextureTransferInfo* source, SDL_GPUTextureRegion* destination, bool isCycle = false)
    {
        assert(state == GPUGraphicState.copyStart);
        assert(lastCopyPass);
        assert(source);
        assert(destination);

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

    void resetState()
    {
        lastCmdBuff = null;
        lastPass = null;
        lastCopyPass = null;
        lastSwapchain = null;
    }

    void bindPipeline(SdlGPUPipeline pipeline)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastPass);

        SDL_BindGPUGraphicsPipeline(lastPass, pipeline.getObject);
    }

    void bindVertexBuffer(SDL_GPUBuffer* vertexBuffer, uint firstSlot = 0, uint offset = 0)
    {
        SDL_GPUBufferBinding[1] bufferBindings;
        bufferBindings[0].buffer = vertexBuffer;
        bufferBindings[0].offset = offset;

        bindVertexBuffer(bufferBindings, firstSlot);
    }

    void bindVertexBuffer(SDL_GPUBufferBinding[] bindings, uint firstSlot = 0)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastPass);
        SDL_BindGPUVertexBuffers(lastPass, firstSlot, bindings.ptr, cast(uint) bindings.length);
    }

    void bindIndexBuffer(SDL_GPUBuffer* indexBuffer, uint offset = 0, SDL_GPUIndexElementSize indexElementSize = SDL_GPU_INDEXELEMENTSIZE_16BIT)
    {
        SDL_GPUBufferBinding indexBinding;
        indexBinding.buffer = indexBuffer;
        indexBinding.offset = offset;

        bindIndexBuffer(&indexBinding, indexElementSize);
    }

    void bindFragmentSamplers(SDL_GPUTexture* texture, SDL_GPUSampler* sampler, uint firstSlot = 0)
    {
        SDL_GPUTextureSamplerBinding[1] sampleBinding;
        sampleBinding[0].texture = texture;
        sampleBinding[0].sampler = sampler;
        bindFragmentSamplers(sampleBinding, firstSlot);
    }

    void bindFragmentSamplers(SDL_GPUTextureSamplerBinding[] bindings, uint firstSlot = 0)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastPass);

        SDL_BindGPUFragmentSamplers(lastPass, firstSlot, bindings.ptr, cast(uint) bindings.length);
    }

    void bindIndexBuffer(SDL_GPUBufferBinding* bindings, SDL_GPUIndexElementSize indexElementSize)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastPass);
        SDL_BindGPUIndexBuffer(lastPass, bindings, indexElementSize);
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

    void drawIndexed(uint numIndices, uint numInstances, uint firstIndex = 0, int vertexOffset = 0, uint firstInstance = 0)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastPass);
        SDL_DrawGPUIndexedPrimitives(lastPass, numIndices, numInstances, firstIndex, vertexOffset, firstInstance);
    }

    void pushUniformFragmentData(uint slotIndex, void* data, uint length)
    {
        assert(state == GPUGraphicState.renderStart);
        assert(lastCmdBuff);
        SDL_PushGPUFragmentUniformData(lastCmdBuff, slotIndex, data, length);
    }

    SDL_GPUColorTargetDescription[1] defaultColorTarget(SDL_Window* window)
    {
        auto format = getSwapchainTextureFormat(window);

        SDL_GPUColorTargetDescription[1] desc = [
            SDL_GPUColorTargetDescription(format)
        ];

        return desc;
    }

    SDL_GPUSamplerCreateInfo nearestRepeat()
    {
        SDL_GPUSamplerCreateInfo info;
        info.min_filter = SDL_GPU_FILTER_NEAREST,
        info.mag_filter = SDL_GPU_FILTER_NEAREST,
        info.mipmap_mode = SDL_GPU_SAMPLERMIPMAPMODE_NEAREST,
        info.address_mode_u = SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
        info.address_mode_v = SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
        info.address_mode_w = SDL_GPU_SAMPLERADDRESSMODE_REPEAT;
        return info;
    }

    SDL_GPUSampler* newSampler(SDL_GPUSamplerCreateInfo* info)
    {
        assert(ptr);
        auto samplerPtr = SDL_CreateGPUSampler(ptr, info);
        if (!samplerPtr)
        {
            throw new Exception("Sampler pointer is null: " ~ getError);
        }
        return samplerPtr;
    }

}
