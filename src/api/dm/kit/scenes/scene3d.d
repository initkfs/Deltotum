module api.dm.kit.scenes.scene3d;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.textures.depth_texture : DepthTexture;
import api.dm.kit.sprites3d.cameras.camera : Camera;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.dm.kit.sprites3d.cameras.orthographic_camera : OrthographicCamera;
import api.dm.kit.scenes.antialiasings.msaa : MSAA;
import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;
import api.dm.kit.scenes.postprocess.bloom.bloom: Bloom;
import api.math.matrices.matrix;

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class Scene3d : Scene2d
{
    Camera camera;

    bool isAntiAliasing = true;
    bool isStencil;

    MSAA msaa;

    SDL_GPUTexture* resultTexture;
    SDL_GPUTexture* renderTexture;

    Bloom postProc;

    DepthTexture depthTexture;
    SDL_GPUDepthStencilTargetInfo depthStencilTargetInfo;

    import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

    SDL_Texture* renderWrapper;

    bool isMix2d3dMode = true;
    bool isMixCurrentPass;

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

        if (isAntiAliasing)
        {
            msaa = new MSAA;
            buildInitCreate(msaa);

            gpu.dev.pipelineTextureFormat = msaa.textureFormat;
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
        if (isAntiAliasing && msaa)
        {
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
    }

    protected SDL_GPUColorTargetInfo createTargetInfo()
    {
        SDL_GPUColorTargetInfo colorTargetInfo;
        SDL_FColor clearColor;
        if (isAntiAliasing)
        {
            assert(msaa);
            colorTargetInfo.texture = msaa.msaaTexture;
            clearColor = SDL_FColor(0, 0, 0, 0);
            colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;

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

        if (isAntiAliasing || isMix2d3dMode)
        {
            SDL_GPUColorTargetInfo[1] targets;
            targets[0] = createTargetInfo;
            if (!gpu.startRenderPass(targets, &depthStencilTargetInfo, isNeedSwapchain))
            {
                gpu.dev.resetState;
                throw new Exception("Error starting gpu rendering with depth");
            }
        }
        else
        {
            if (!gpu.startCmdBuffer(&depthStencilTargetInfo, isNeedSwapchain))
            {
                gpu.dev.resetState;
                throw new Exception("Error starting gpu command buffer");
            }

            auto target = gpu.defaultSwapchainTarget;

            if (!gpu.beginRenderPass(target, &depthStencilTargetInfo))
            {
                gpu.dev.resetState;
                throw new Exception("Error starting gpu rendering with depth");
            }
        }

        //import api.math.geom2.rect2: Rect2f;
        //gpu.dev.setScissorRect(Rect2f(0, 0, window.width, window.height));

        drawSelfAndChildren(alpha);
        isMixCurrentPass = true;

        if (isAntiAliasing || isMix2d3dMode)
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

        postProc.process(resultTexture, renderTexture, isMix2d3dMode);

        gpu.dev.endRenderPass(isSubmit : false);

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

        if(!gpu.dev.submitCmdBuffer){
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
        
        if(postProc){
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

        if (msaa)
        {
            msaa.dispose;
        }
    }
}
