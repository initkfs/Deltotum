module api.dm.kit.scenes.scene3d;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.textures.depth_texture : DepthTexture;
import api.dm.kit.sprites3d.cameras.camera : Camera;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.dm.kit.sprites3d.cameras.orthographic_camera : OrthographicCamera;
import api.dm.kit.scenes.antialiasings.antialiaser : AntiAliaser;
import api.dm.kit.scenes.antialiasings.msaa : MSAA;
import api.dm.kit.scenes.antialiasings.fxaa : FXAA;
import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;
import api.dm.kit.scenes.postprocess.bloom.bloom : Bloom;
import api.math.matrices.matrix;

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

//TODO heat
import api.dm.kit.sprites3d.textures.heat_texture_array : HeatTextureArray;

/**
 * Authors: initkfs
 */

enum AntiAliasing
{
    msaa,
    fxaa,
    none
}

class Scene3d : Scene2d
{
    Camera camera;

    AntiAliasing aaType = AntiAliasing.msaa;
    AntiAliaser antiAliaser;

    bool isStencil;

    SDL_GPUTexture* resultTexture;
    SDL_GPUTexture* renderTexture;

    Bloom postProc;

    DepthTexture depthTexture;
    SDL_GPUDepthStencilTargetInfo depthStencilTargetInfo;

    import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

    SDL_Texture* renderWrapper;

    bool isMix2d3dMode = true;
    bool isMixCurrentPass;

    HeatTextureArray heatMaps1;
    HeatTextureArray heatMaps2;
    bool isReadMap1 = true;
    bool isHeatMap = true;

    SDL_GPUComputePipeline* heatPipeline;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor);
        initProcessUDA!ThisType(isInitUDAProcessor);
        isAutoSizeToWindow = true;
    }

    override void create()
    {
        super.create;

        if (!platform.cap.isGPU)
        {
            return;
        }

        camera = createCamera;
        assert(camera);

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        if (config.hasKey(KitConfigKeys.backendAntiAliasing))
        {
            import std.conv : to;

            aaType = config.getNotEmptyString(KitConfigKeys.backendAntiAliasing).to!AntiAliasing;
        }

        version (EnableTrace)
        {
            import std.conv : to;

            logger.trace("Antialiasing: " ~ aaType.to!string);
        }

        final switch (aaType) with (AntiAliasing)
        {
            case msaa:
                antiAliaser = new MSAA;
                gpu.dev.pipelineTextureFormat = antiAliaser.textureFormat;
                break;
            case fxaa:
                antiAliaser = new FXAA;
                break;
            case none:
                break;
        }

        if (antiAliaser)
        {
            buildInitCreate(antiAliaser);
        }

        gpu.dev.isStencil = isStencil;

        SDL_GPUTextureCreateInfo resultTextureInfo;
        resultTextureInfo.type = SDL_GPU_TEXTURETYPE_2D;
        resultTextureInfo.width = window.widthu;
        resultTextureInfo.height = window.heightu;
        resultTextureInfo.layer_count_or_depth = 1;
        resultTextureInfo.num_levels = 1;
        resultTextureInfo.format = gpu.dev.pipelineTextureFormat;
        resultTextureInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;
        resultTexture = SDL_CreateGPUTexture(gpu.dev.ptr, &resultTextureInfo);
        assert(resultTexture);

        renderTexture = SDL_CreateGPUTexture(gpu.dev.ptr, &resultTextureInfo);
        assert(renderTexture);

        if (isMix2d3dMode)
        {
            assert(renderTexture);
            SDL_PropertiesID props = SDL_CreateProperties();
            SDL_SetPointerProperty(props, SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_POINTER, renderTexture);
            SDL_SetNumberProperty(props, SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER, window.widthu);
            SDL_SetNumberProperty(props, SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER, window.heightu);
            SDL_SetNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, gpu
                    .dev.pipelineTextureFormat);
            renderWrapper = SDL_CreateTextureWithProperties(
                cast(SDL_Renderer*) window.renderer.rawPtr, props);
            SDL_DestroyProperties(props);
        }

        if (isStencil)
        {
            gpu.dev.depthTextureFormat = gpu.dev.depthTextureStencilFormat;
        }

        depthTexture = new DepthTexture;
        if (antiAliaser && aaType == AntiAliasing.msaa)
        {
            MSAA msaa = cast(MSAA) antiAliaser;
            assert(msaa);
            depthTexture.sampleCount = msaa.aliasingSampleCount;
            depthTexture.isMultiSampler = true;
        }

        build(depthTexture);
        depthTexture.create;

        depthStencilTargetInfo.texture = depthTexture.texture;
        depthStencilTargetInfo.cycle = true;
        depthStencilTargetInfo.clear_depth = 0;
        depthStencilTargetInfo.clear_stencil = 0;
        depthStencilTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
        //depthStencilTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
        depthStencilTargetInfo.store_op = SDL_GPU_STOREOP_DONT_CARE;
        depthStencilTargetInfo.stencil_load_op = SDL_GPU_LOADOP_CLEAR;
        //depthStencilTargetInfo.stencil_store_op = SDL_GPU_STOREOP_STORE;
        depthStencilTargetInfo.stencil_store_op = SDL_GPU_STOREOP_DONT_CARE;

        postProc = new Bloom;
        build(postProc);
        postProc.create;

        heatMaps1 = new HeatTextureArray;
        build(heatMaps1);
        heatMaps1.create;

        heatMaps2 = new HeatTextureArray;
        build(heatMaps2);
        heatMaps2.create;

        import std.path : buildPath;
        import api.dm.com.graphics.gpu.com_pipeline : ComComputeBuffers;

        ComComputeBuffers buffs;
        buffs.numRTextures = 1;
        buffs.numRWTextures = 1;
        buffs.numUniforms = 1;

        // gpu.dev.startCopyPass;
        // heatMaps1.uploadStart;
        // heatMaps2.uploadStart;
        // gpu.dev.endCopyPass;

        auto compShaderPath = buildPath(context.app.dataDir, "shaders", "out", "spirv", "HeatCompute.comp.spv");
        heatPipeline = gpu.dev.createComputePipelineSPIRV(compShaderPath, buffs);
    }

    protected SDL_GPUColorTargetInfo createTargetInfo()
    {
        SDL_GPUColorTargetInfo colorTargetInfo;
        SDL_FColor clearColor;
        if (antiAliaser && aaType == AntiAliasing.msaa)
        {
            colorTargetInfo.texture = antiAliaser.texture;
            clearColor = SDL_FColor(0, 0, 0, 0);
            colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;

            auto msaa = cast(MSAA) antiAliaser;
            assert(msaa);

            if (msaa.aliasingSampleCount == SDL_GPU_SAMPLECOUNT_1)
            {
                colorTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
            }
            else
            {
                colorTargetInfo.store_op = SDL_GPU_STOREOP_RESOLVE;
                colorTargetInfo.resolve_texture = resultTexture;
            }
        }
        else
        {
            colorTargetInfo.texture = resultTexture;
            clearColor = SDL_FColor(0, 0, 0, 1);
            colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
            colorTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
        }

        colorTargetInfo.clear_color = clearColor;
        colorTargetInfo.cycle = true;

        return colorTargetInfo;
    }

    override void drawAll(float alpha)
    {
        if ((!gpu) || (!platform.cap.isGPU))
        {
            super.drawAll(alpha);
            return;
        }

        bool isNeedSwapchain = true;
        if (isMix2d3dMode)
        {
            isMixCurrentPass = false;
            isNeedSwapchain = false;
        }

        import api.dm.back.sdl3.externs.csdl3;

        if (!gpu.startCmdBuffer(&depthStencilTargetInfo, isNeedSwapchain))
        {
            gpu.dev.resetState;
            throw new Exception("Error starting gpu command buffer");
        }

        SDL_GPUStorageTextureReadWriteBinding rwBinding;
        auto outHeatTexture = isReadMap1 ? heatMaps2.texture : heatMaps1.texture;
        rwBinding.texture = outHeatTexture;
        rwBinding.mip_level = 0;
        rwBinding.layer = 0;
        rwBinding.cycle = true;

        gpu.dev.startComputePass(&rwBinding, null, 1, 0);
        gpu.dev.bindComputePipeline(heatPipeline);

        struct ThermalParams
        {
            float deltaTime = 0; //0.016
            float conductivity = 1; //1
            float coolingRate = 1;
            float ambientTemp = 20;
        }

        ThermalParams params;
        params.deltaTime = 1.0 / window.frameRate;
        gpu.dev.pushComputeUniform(&params, params.sizeof, 0);

        auto inputTexture = isReadMap1 ? heatMaps1 : heatMaps2;
        auto inputGpu = inputTexture.texture;
        gpu.dev.bindComputeStorageTextures(&inputGpu);

        isReadMap1 = !isReadMap1;

        size_t numThreads = 16;
        uint threadsCount = heatMaps1.widthu / numThreads;
        uint groupCountX = threadsCount;
        uint groupCountY = threadsCount;
        uint groupCountZ = 3;
        gpu.dev.dispatchCompute(groupCountX, groupCountY, groupCountZ);
        gpu.dev.endComputePass;

        if (antiAliaser || isMix2d3dMode)
        {
            SDL_GPUColorTargetInfo[1] targets;
            targets[0] = createTargetInfo;

            if (!gpu.beginRenderPass(targets, &depthStencilTargetInfo))
            {
                gpu.dev.resetState;
                throw new Exception("Error starting gpu rendering with depth");
            }
        }
        else
        {
            auto target = gpu.defaultSwapchainTarget;

            if (!gpu.beginRenderPass(target, &depthStencilTargetInfo))
            {
                gpu.dev.resetState;
                throw new Exception("Error starting gpu rendering with depth");
            }
        }

        //import api.math.geom2.rect2: Rect2f;
        //gpu.dev.setScissorRect(Rect2f(0, 0, window.width, window.height));

        gpu.dev.bindFragmentSamplers(inputTexture, 6);

        drawSelfAndChildren(alpha);
        isMixCurrentPass = true;

        if (antiAliaser || isMix2d3dMode)
        {
            if (!gpu.dev.endRenderPass(isSubmit : false))
            {
                gpu.dev.resetState;
                throw new Exception("Error ending gpu renderer");
            }
        }
        else
        {
            if (!gpu.dev.endRenderPass)
            {
                gpu.dev.resetState;
                throw new Exception("Error ending gpu renderer");
            }
        }

        auto outPostTexture = renderTexture;
        if (antiAliaser && aaType == AntiAliasing.fxaa)
        {
            outPostTexture = antiAliaser.texture;
        }

        postProc.process(resultTexture, outPostTexture, isMix2d3dMode);

        gpu.dev.endRenderPass(isSubmit : false);

        if (antiAliaser && aaType == AntiAliasing.fxaa)
        {
            antiAliaser.process(null, renderTexture, isMix2d3dMode);
        }

        gpu.dev.submitCmdBuffer;
        gpu.dev.resetState;

        if (isMix2d3dMode)
        {
            graphic.clear;
            graphic.rendererFlush;

            assert(renderWrapper);
            SDL_Renderer* ptr = cast(SDL_Renderer*) window.renderer.rawPtr;
            SDL_RenderTexture(ptr, renderWrapper, null, null);

            drawSelfAndChildren(alpha);

            graphic.rendererPresent;
        }

        // gpu.dev.startCopyPass;
        // uint textureSizeInBytes = 64 * 64 * 256 * float.sizeof;
        // auto db = gpu.dev.newTransferDownloadBuffer(textureSizeInBytes);
        // SDL_GPUTextureTransferInfo srcInfo;
        // srcInfo.transfer_buffer = db;
        // srcInfo.offset = 0;
        // SDL_GPUTextureRegion srcRegion;
        // srcRegion.texture = outHeatTexture;
        // srcRegion.w = heatMaps2.widthu;
        // srcRegion.h = heatMaps2.heightu;
        // srcRegion.d = cast(uint) heatMaps2.count;
        // gpu.dev.downloadTexture(&srcRegion, &srcInfo);
        // gpu.dev.endCopyPass(true, true);

        // void* mappedData = gpu.dev.mapTransferBuffer(db, true);
        // float* rawHalfData = cast(float*) mappedData;
        // float[] slice = rawHalfData[5.. 20];

        // import std.stdio;
        // import std.conv: to;
        // writeln(slice);

        // gpu.dev.unmapTransferBuffer(db);
        // gpu.dev.deleteTransferBuffer(db);

        //TODO flush?
    }

    PerspectiveCamera newPerspCamera() => new PerspectiveCamera(this);
    OrthographicCamera newOrthoCamera() => new OrthographicCamera(this);

    Camera createCamera()
    {
        camera = newPerspCamera;
        build(camera);
        camera.create;
        assert(camera.isCreated);
        return camera;
    }

    override bool addCreate(Sprite2d object)
    {
        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                if (!camera)
                {
                    throw new Exception("Not found camera in scene");
                }
                sprite3d.camera = camera;
            }
        }
        return super.addCreate(object);
    }

    override bool add(Sprite2d object)
    {
        if (!super.add(object))
        {
            return false;
        }

        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                sprite3d.camera = camera;
            }
        }

        return true;
    }

    void uploadStart()
    {

    }

    void uploadEnd()
    {

    }

    void uploadToGPU()
    {
        if (!platform.cap.isGPU)
        {
            return;
        }

        if (!gpu.dev.startCopyPass)
        {
            throw new Exception("Unable to start copy pass");
        }

        uploadStart;

        foreach (sprite; sprites)
        {
            if (auto sprite3d = cast(Sprite3d) sprite)
            {
                sprite3d.uploadStart;
            }
        }

        uploadEnd;

        gpu.dev.endCopyPass(isSubmitBuffer : false);

        foreach (sprite; sprites)
        {
            if (auto sprite3d = cast(Sprite3d) sprite)
            {
                sprite3d.uploadEnd;
            }
        }

        if (!gpu.dev.submitCmdBuffer)
        {
            throw new Exception("Error submit command buffer");
            gpu.dev.resetState;
        }

    }

    override bool checkForDraw(Sprite2d sprite)
    {
        if (!super.checkForDraw(sprite))
        {
            return false;
        }

        if (!isMix2d3dMode)
        {
            return true;
        }

        import api.dm.kit.sprites3d.sprite3d : Sprite3d;

        auto sprite3 = cast(Sprite3d) sprite;
        if (sprite3)
        {
            return isMixCurrentPass ? false : true;
        }

        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        if (camera)
        {
            camera.update(dt);
        }
    }

    override void dispose()
    {
        super.dispose;

        if (postProc)
        {
            postProc.dispose;
        }

        if (camera)
        {
            camera.dispose;
        }

        if (depthTexture)
        {
            depthTexture.dispose;
        }

        if (resultTexture)
        {
            gpu.dev.deleteTexture(resultTexture);
        }

        if (renderTexture)
        {
            gpu.dev.deleteTexture(renderTexture);
        }

        if (antiAliaser)
        {
            antiAliaser.dispose;
        }

        if (heatMaps1)
        {
            heatMaps1.dispose;
        }

        if (heatMaps2)
        {
            heatMaps2.dispose;
        }

        if (heatPipeline)
        {
            gpu.dev.deleteComputePipeline(heatPipeline);
        }
    }
}
