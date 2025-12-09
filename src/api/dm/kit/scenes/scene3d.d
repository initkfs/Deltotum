module api.dm.kit.scenes.scene3d;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.textures.depth_texture : DepthTexture;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.math.matrices.matrix;

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

struct SceneTransforms
{
    Matrix4x4 world;
    Matrix4x4 camera;
    Matrix4x4 projection;
    Matrix4x4 normal;
}

class Scene3d : Scene2d
{
    PerspectiveCamera camera;

    bool isDepth = true;
    bool isAntiAliasing;

    SDL_GPUSampleCount aliasingSampleCount = SDL_GPU_SAMPLECOUNT_4;

    SDL_GPUTexture* msaaTexture;
    SDL_GPUTexture* resultTexture;

    DepthTexture depthTexture;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor);
        initProcessUDA!ThisType(isInitUDAProcessor);
    }

    override void create()
    {
        super.create;

        if (gpu.isActive)
        {
            camera = createCamera;
            assert(camera);

            if (isAntiAliasing)
            {
                auto format = gpu.getSwapchainTextureFormat;
                if (SDL_GPUTextureSupportsSampleCount(gpu.dev.getObject, format, aliasingSampleCount))
                {
                    gpu.dev.isUseSampleCount = true;
                    gpu.dev.sampleCount = aliasingSampleCount;

                    SDL_GPUTextureCreateInfo msaTextureInfo;
                    msaTextureInfo.type = SDL_GPU_TEXTURETYPE_2D;
                    msaTextureInfo.width = window.widthu;
                    msaTextureInfo.height = window.heightu;
                    msaTextureInfo.layer_count_or_depth = 1;
                    msaTextureInfo.num_levels = 1;
                    msaTextureInfo.format = format;
                    msaTextureInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET;
                    msaTextureInfo.sample_count = aliasingSampleCount;

                    if (aliasingSampleCount == SDL_GPU_SAMPLECOUNT_1)
                    {
                        msaTextureInfo.usage |= SDL_GPU_TEXTUREUSAGE_SAMPLER;
                    }

                    msaaTexture = SDL_CreateGPUTexture(gpu.dev.getObject, &msaTextureInfo);
                    assert(msaaTexture);

                    SDL_GPUTextureCreateInfo resultTextureInfo;
                    resultTextureInfo.type = SDL_GPU_TEXTURETYPE_2D;
                    resultTextureInfo.width = window.widthu;
                    resultTextureInfo.height = window.heightu;
                    resultTextureInfo.layer_count_or_depth = 1;
                    resultTextureInfo.num_levels = 1;
                    resultTextureInfo.format = format;
                    resultTextureInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;

                    resultTexture = SDL_CreateGPUTexture(gpu.dev.getObject, &resultTextureInfo);
                    assert(resultTexture);
                }
                else
                {
                    logger.errorf("Texture format %s not supported with sample count: %s", format, aliasingSampleCount);
                    isAntiAliasing = false;
                }
            }

            if (isDepth)
            {
                depthTexture = new DepthTexture;
                if (isAntiAliasing)
                {
                    depthTexture.sampleCount = aliasingSampleCount;
                    depthTexture.isMultiSampler = true;
                }
                build(depthTexture);
                depthTexture.create;
            }
        }
    }

    PerspectiveCamera createCamera()
    {
        camera = new PerspectiveCamera(this);
        build(camera);
        camera.create;
        assert(camera.isCreated);
        return camera;
    }

    override void addCreate(Sprite2d object)
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
        super.addCreate(object);
    }

    override void add(Sprite2d object)
    {
        super.add(object);

        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                sprite3d.camera = camera;
            }
        }
    }

    void uploadStart()
    {

    }

    void uploadEnd()
    {

    }

    void uploadToGPU()
    {
        if (!gpu.isActive)
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

        if (!gpu.dev.endCopyPass)
        {
            throw new Exception("Unable to end copy pass");
        }

        foreach (sprite; sprites)
        {
            if (auto sprite3d = cast(Sprite3d) sprite)
            {
                sprite3d.uploadEnd;
            }
        }
    }

    protected SDL_GPUColorTargetInfo createTargetInfo()
    {
        SDL_GPUColorTargetInfo colorTargetInfo;
        colorTargetInfo.texture = msaaTexture;
        colorTargetInfo.clear_color = gpu.dev.clearColor;
        colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;

        if (aliasingSampleCount == SDL_GPU_SAMPLECOUNT_1)
        {
            colorTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
        }
        else
        {
            colorTargetInfo.store_op = SDL_GPU_STOREOP_RESOLVE;
            colorTargetInfo.resolve_texture = resultTexture;
        }
        return colorTargetInfo;
    }

    override void drawAll()
    {
        bool isGPU = gpu.isActive;

        if (!isGPU)
        {
            super.drawAll;
            return;
        }

        if (isDepth && depthTexture)
        {
            import api.dm.back.sdl3.externs.csdl3;

            SDL_GPUDepthStencilTargetInfo depthStencilTargetInfo;
            depthStencilTargetInfo.texture = depthTexture.texture;
            depthStencilTargetInfo.cycle = true;
            depthStencilTargetInfo.clear_depth = 1;
            depthStencilTargetInfo.clear_stencil = 0;
            depthStencilTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
            depthStencilTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
            depthStencilTargetInfo.stencil_load_op = SDL_GPU_LOADOP_CLEAR;
            depthStencilTargetInfo.stencil_store_op = SDL_GPU_STOREOP_STORE;

            if (isAntiAliasing)
            {
                SDL_GPUColorTargetInfo[1] targets = [createTargetInfo];
                if (!gpu.startRenderPass(targets, &depthStencilTargetInfo))
                {
                    gpu.dev.resetState;
                    throw new Exception("Error starting gpu rendering with depth");
                }
            }
            else
            {
                if (!gpu.startRenderPass(&depthStencilTargetInfo))
                {
                    gpu.dev.resetState;
                    throw new Exception("Error starting gpu rendering with depth");
                }
            }

        }
        else
        {
            if (isAntiAliasing)
            {
                SDL_GPUColorTargetInfo[1] targets = [createTargetInfo];
                if (!gpu.startRenderPass(targets))
                {
                    gpu.dev.resetState;
                    throw new Exception("Error starting gpu rendering with depth");
                }
            }
            else
            {
                if (!gpu.startRenderPass)
                {
                    gpu.dev.resetState;
                    throw new Exception("Error starting gpu rendering");
                }
            }

        }

        drawSelfAndChildren;

        if (isAntiAliasing)
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

        if (resultTexture)
        {
            SDL_GPUBlitInfo blitInfo;

            uint w = window.widthu;
            uint h = window.heightu;

            blitInfo.source.texture = resultTexture;
            blitInfo.source.w = w;
            blitInfo.source.h = h;
            blitInfo.destination.texture = gpu.dev.swapchain;
            blitInfo.destination.w = w;
            blitInfo.destination.h = h;
            blitInfo.load_op = SDL_GPU_LOADOP_DONT_CARE;
            blitInfo.filter = SDL_GPU_FILTER_LINEAR;

            SDL_BlitGPUTexture(gpu.dev.cmdBuff, &blitInfo);

            gpu.dev.submitCmdBuffer;
            gpu.dev.resetState;
        }
    }

    override protected void drawSelfAndChildren()
    {
        if (!gpu.isActive)
        {
            super.drawSelfAndChildren;
            return;
        }

        if (!isDrawAfterAllSprites && !drawBeforeSprite)
        {
            drawSelf;
        }

        foreach (obj; sprites)
        {
            auto sprite3d = cast(Sprite3d) obj;
            if (!sprite3d)
            {
                continue;
            }

            sprite3d.draw;
            sprite3d.unvalidate;
        }

        if (isDrawAfterAllSprites && !drawBeforeSprite)
        {
            drawSelf;
        }

        startDrawProcess = false;
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

        if (msaaTexture)
        {
            gpu.dev.deleteTexture(msaaTexture);
        }
    }
}
