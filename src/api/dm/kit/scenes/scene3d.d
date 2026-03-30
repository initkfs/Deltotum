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
    bool isAntiAliasing = true;

    SDL_GPUSampleCount aliasingSampleCount = SDL_GPU_SAMPLECOUNT_4;

    SDL_GPUTexture* msaaTexture;
    SDL_GPUTexture* resultTexture;

    SDL_GPUTexture* bloomA;
    SDL_GPUSampler* bloomSampler;
    SDL_GPUTexture* bloomB;

    DepthTexture depthTexture;

    import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

    SdlGPUPipeline brightPipeline;
    SdlGPUPipeline blurPipeline;
    SdlGPUPipeline composePipeline;

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
            auto format = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;
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

                debug
                {
                    import std.conv : to;

                    throw new Exception("Unsupported msaa format: " ~ format.to!string);
                }
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

        uint bloomW = window.widthu / 4;
        uint bloomH = window.heightu / 4;

        SDL_GPUTextureCreateInfo bloomInfo;
        bloomInfo.type = SDL_GPU_TEXTURETYPE_2D;
        bloomInfo.width = bloomW;
        bloomInfo.height = bloomH;
        bloomInfo.layer_count_or_depth = 1;
        bloomInfo.num_levels = 1;
        bloomInfo.format = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;
        bloomInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;

        bloomA = gpu.dev.newTexture(&bloomInfo);
        bloomB = gpu.dev.newTexture(&bloomInfo);

        SDL_GPURasterizerState raster;
        raster.fill_mode = SDL_GPU_FILLMODE_FILL;
        raster.cull_mode = SDL_GPU_CULLMODE_NONE;

        SDL_GPUDepthStencilState depth;
        depth.enable_depth_test = false;
        depth.enable_depth_write = false;

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;
        targetInfo.num_color_targets = 1;
        SDL_GPUColorTargetDescription colorDesc;
        colorDesc.format = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;
        colorDesc.blend_state.enable_blend = false;
        targetInfo.color_target_descriptions = &colorDesc;

        import std.path: buildPath;
        auto shaderDir = buildPath(context.app.dataDir, "shaders", "out", "spirv");

        brightPipeline = gpu.newPipeline(
            buildPath(shaderDir, "Bright.vert.spv"),
            buildPath(shaderDir, "Bright.frag.spv"),
            0, 0, 0, 0,
            1, 0, 0, 0,
            &raster,
            &depth,
            &targetInfo,
            "BrightPassPipeline", 
            false,
            false
        );

        blurPipeline = gpu.newPipeline(
            buildPath(shaderDir, "Bright.vert.spv"),
            buildPath(shaderDir, "Blur.frag.spv"),
            0, 0, 0, 0,
            1, 0, 1, 0,
            &raster,
            &depth,
            &targetInfo,
            "BlurPassPipeline", 
            false,
            false
        );

         colorDesc.format = gpu.getSwapchainTextureFormat;

        composePipeline = gpu.newPipeline(
            buildPath(shaderDir, "Bright.vert.spv"),
            buildPath(shaderDir, "BlurCompose.frag.spv"),
            0, 0, 0, 0,
            2, 0, 0, 0,
            &raster,
            &depth,
            &targetInfo,
            "BlurComposePassPipeline", 
            false,
            false
        );

        SDL_GPUSamplerCreateInfo samplerInfo;
        samplerInfo.min_filter = SDL_GPU_FILTER_LINEAR;
        samplerInfo.mag_filter = SDL_GPU_FILTER_LINEAR;
        samplerInfo.mipmap_mode = SDL_GPU_SAMPLERMIPMAPMODE_LINEAR;
        samplerInfo.address_mode_u = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;
        samplerInfo.address_mode_v = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;
        samplerInfo.address_mode_w = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;

        bloomSampler = gpu.dev.newSampler(&samplerInfo);

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
        SDL_FColor clearColor;
        if (isAntiAliasing)
        {
            colorTargetInfo.texture = msaaTexture;
            clearColor = SDL_FColor(0, 0, 0, 0);
        }
        else
        {
            colorTargetInfo.texture = gpu.dev.swapchain;
            clearColor = SDL_FColor(0, 0, 0, 1);
        }

        colorTargetInfo.clear_color = clearColor;
        colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
        colorTargetInfo.cycle = true;

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

            // blitInfo.source.texture = resultTexture;
            // blitInfo.source.w = w;
            // blitInfo.source.h = h;
            // blitInfo.destination.texture = gpu.dev.swapchain;
            // blitInfo.destination.w = w;
            // blitInfo.destination.h = h;
            // blitInfo.load_op = SDL_GPU_LOADOP_DONT_CARE;
            // blitInfo.filter = SDL_GPU_FILTER_LINEAR;

            // SDL_BlitGPUTexture(gpu.dev.cmdBuff, &blitInfo);

            //Bright Pass
            //Horizontal Blur
            //Vertical Blur
            SDL_GPUColorTargetInfo[1] targets;

            SDL_GPUColorTargetInfo brightPassTarget;
            brightPassTarget.texture = bloomA;
            brightPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
            brightPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
            brightPassTarget.cycle = true;
            brightPassTarget.store_op = SDL_GPU_STOREOP_STORE;
            targets[0] = brightPassTarget;

            uint bloomW = window.widthu / 4;
            uint bloomH = window.heightu / 4;

            import api.math.geom2.rect2 : Rect2f;

            gpu.dev.beginRenderPass(targets);
            gpu.dev.setViewport(Rect2f(0, 0, bloomW, bloomH), 0, 1);
            gpu.dev.bindPipeline(brightPipeline);
            gpu.dev.bindFragmentSamplers(resultTexture, bloomSampler, 0);
            gpu.dev.draw(3, 1, 0, 0);

            gpu.dev.endRenderPass(isSubmit : false);

            SDL_GPUColorTargetInfo horizontPassTarget;
            horizontPassTarget.texture = bloomB;
            horizontPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
            horizontPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
            horizontPassTarget.store_op = SDL_GPU_STOREOP_STORE;
            horizontPassTarget.cycle = true;
            targets[0] = horizontPassTarget;

            gpu.dev.beginRenderPass(targets);
            gpu.dev.bindPipeline(blurPipeline);
            align(16) float[4] data = [1, 0, 1.0/bloomW, 1.0/bloomH];
            gpu.dev.pushUniformFragmentData(0, data.ptr, data.sizeof);
            gpu.dev.bindFragmentSamplers(bloomA, bloomSampler, 0);
            gpu.dev.draw(3, 1, 0, 0);
            gpu.dev.endRenderPass(isSubmit : false);

            SDL_GPUColorTargetInfo vertPassTarget;
            vertPassTarget.texture = bloomA;
            vertPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
            vertPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
            vertPassTarget.store_op = SDL_GPU_STOREOP_STORE;
            vertPassTarget.cycle = true;
            targets[0] = vertPassTarget;

            gpu.dev.beginRenderPass(targets);
            gpu.dev.bindPipeline(blurPipeline);
            align(16) float[4] data1 = [0, 1, 1.0/bloomW, 1.0/bloomH];
            gpu.dev.pushUniformFragmentData(0, data1.ptr, data1.sizeof);
            gpu.dev.bindFragmentSamplers(bloomB, bloomSampler, 0);
            gpu.dev.draw(3, 1, 0, 0);
            gpu.dev.endRenderPass(isSubmit : false);

            SDL_GPUColorTargetInfo composePassTarget;
            composePassTarget.texture = gpu.dev.swapchain;
            composePassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
            composePassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
            composePassTarget.store_op = SDL_GPU_STOREOP_STORE;
            composePassTarget.cycle = true;
            targets[0] = composePassTarget;

            gpu.dev.beginRenderPass(targets);
            gpu.dev.setViewport(Rect2f(0, 0, window.widthu, window.heightu), 0, 1);
            gpu.dev.bindPipeline(composePipeline);
            gpu.dev.bindFragmentSamplers(resultTexture, bloomSampler, 0);
            gpu.dev.bindFragmentSamplers(bloomA, bloomSampler, 1);
            gpu.dev.draw(3, 1, 0, 0);
            gpu.dev.endRenderPass(isSubmit : false);

            // blitInfo = SDL_GPUBlitInfo.init;

            // blitInfo.source.texture = bloomA;
            // blitInfo.source.w = bloomW;
            // blitInfo.source.h = bloomH;
            // blitInfo.destination.texture = gpu.dev.swapchain;
            // blitInfo.destination.w = w;
            // blitInfo.destination.h = h;
            // blitInfo.load_op = SDL_GPU_LOADOP_DONT_CARE;
            // blitInfo.filter = SDL_GPU_FILTER_LINEAR;

            // SDL_BlitGPUTexture(gpu.dev.cmdBuff, &blitInfo);

            // SDL_GPUColorTargetInfo resultPassTarget;
            // resultPassTarget.texture = gpu.dev.swapchain;
            // resultPassTarget.load_op = SDL_GPU_LOADOP_CLEAR;
            // resultPassTarget.clear_color = SDL_FColor(0, 0, 0, 1);
            // resultPassTarget.store_op = SDL_GPU_STOREOP_STORE;
            // resultPassTarget.cycle = true;
            // targets[0] = resultPassTarget;

            // gpu.dev.beginRenderPass(targets);
            // gpu.dev.setViewport(Rect2f(0, 0, bloomW, bloomH), 0, 1);
            // //gpu.dev.draw(3, 1, 0, 0);
            // gpu.dev.endRenderPass(isSubmit : false);

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
