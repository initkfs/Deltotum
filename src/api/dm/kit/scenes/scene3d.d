module api.dm.kit.scenes.scene3d;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.textures.depth_texture : DepthTexture;
import api.dm.kit.sprites3d.cameras.camera : Camera;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.dm.kit.sprites3d.cameras.orthographic_camera : OrthographicCamera;
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
    Camera camera;

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
        isAutoSizeToWindow = true;
    }

    override void create()
    {
        super.create;

        if (platform.cap.isGPU)
        {
            camera = createCamera;
            assert(camera);

            if (isAntiAliasing)
            {
                auto format = gpu.getSwapchainTextureFormat;
                if (SDL_GPUTextureSupportsSampleCount(gpu.dev.ptr, format, aliasingSampleCount))
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

                    msaaTexture = SDL_CreateGPUTexture(gpu.dev.ptr, &msaTextureInfo);
                    assert(msaaTexture);

                    SDL_GPUTextureCreateInfo resultTextureInfo;
                    resultTextureInfo.type = SDL_GPU_TEXTURETYPE_2D;
                    resultTextureInfo.width = window.widthu;
                    resultTextureInfo.height = window.heightu;
                    resultTextureInfo.layer_count_or_depth = 1;
                    resultTextureInfo.num_levels = 1;
                    resultTextureInfo.format = format;
                    resultTextureInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;

                    resultTexture = SDL_CreateGPUTexture(gpu.dev.ptr, &resultTextureInfo);
                    assert(resultTexture);
                }
                else
                {
                    int tformat = format;
                    int sampleCount = aliasingSampleCount;
                    logger.errorf("Texture format %d not supported with sample count: %d", tformat, sampleCount);
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

    PerspectiveCamera newPerspCamera()
    {
        return new PerspectiveCamera(this);
    }

    OrthographicCamera newOrthoCamera()
    {
        return new OrthographicCamera(this);
    }

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
        if (isAntiAliasing)
        {
            colorTargetInfo.texture = msaaTexture;
        }
        else
        {
            colorTargetInfo.texture = gpu.dev.swapchain;
        }

        colorTargetInfo.clear_color = gpu.dev.clearColor;
        colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;

        if (isAntiAliasing)
        {
            if (aliasingSampleCount == SDL_GPU_SAMPLECOUNT_1)
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
            colorTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
            colorTargetInfo.cycle = true;
        }
        return colorTargetInfo;
    }

    override void drawAll(float alpha)
    {
        if ((!gpu) || (!platform.cap.isGPU))
        {
            super.drawAll(alpha);
            return;
        }

        //graphic.clear;

        if (isDepth && depthTexture)
        {
            import api.dm.back.sdl3.externs.csdl3;

            SDL_GPUDepthStencilTargetInfo depthStencilTargetInfo;
            depthStencilTargetInfo.texture = depthTexture.texture;
            depthStencilTargetInfo.cycle = true;
            depthStencilTargetInfo.clear_depth = 0;
            depthStencilTargetInfo.clear_stencil = 0;
            depthStencilTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
            depthStencilTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
            //depthStencilTargetInfo.store_op = SDL_GPU_STOREOP_DONT_CARE;
            depthStencilTargetInfo.stencil_load_op = SDL_GPU_LOADOP_CLEAR;
            depthStencilTargetInfo.stencil_store_op = SDL_GPU_STOREOP_STORE;

            if (isAntiAliasing)
            {
                SDL_GPUColorTargetInfo[1] targets;
                targets[0] = createTargetInfo;
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
                SDL_GPUColorTargetInfo[1] targets;
                targets[0] = createTargetInfo;
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

        drawSelfAndChildren(alpha);
        graphic.clear;

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

        //TODO flush?
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
