module api.demo.demo1.scenes.start;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;

import api.dm.kit.sprites2d.tweens;
import api.dm.kit.sprites2d.images;

import Math = api.dm.math;
import api.math.random : Random;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.vec3 : Vec3f;

import api.dm.kit.factories;

import std : writeln;

import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.back.sdl3.gpu.sdl_gpu_shader : SdlGPUShader;
import api.dm.kit.sprites3d.cameras.perspective_camera: PerspectiveCamera;
import api.dm.com.gpu.com_3d_types: ComVertex;
import api.dm.kit.sprites3d.primitives.cube: Cube;

import api.dm.back.sdl3.externs.csdl3;

import api.math.matrices.matrix;
import api.core.utils.text;

/**
 * Authors: initkfs
 */
class Start : GuiScene
{

    SdlGPUPipeline fillPipeline;

    SDL_Window* winPtr;

    Random rnd;

    Cube cube;

    SDL_GPUTexture* newTexture;
    SDL_GPUSampler* sampler;

    SDL_GPUTexture* sceneDepthTexture;

    PerspectiveCamera camera;

    struct UniformBuffer
    {
        float time = 0;
        // you can add other properties here
    }

    static UniformBuffer timeUniform;

    override void create()
    {
        super.create;
        rnd = new Random;

        camera = new PerspectiveCamera(this);
        addCreate(camera);

        cube = new Cube(1, 1, 1);
        addCreate(cube);

        import api.dm.gui.windows.gui_window : GuiWindow;

        //TODO remove test
        import std.file : read;

        auto vertShaderFile = context.app.userDir ~ "/shaders/TexturedBox.vert.spv";
        auto fragShaderFile = context.app.userDir ~ "/shaders/TexturedBox.frag.spv";

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = gpu.getSwapchainTextureFormat;
        targetInfo.num_color_targets = 1;
        targetInfo.color_target_descriptions = targetDesc.ptr;
        targetInfo.has_depth_stencil_target = true;
        targetInfo.depth_stencil_format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;

        auto stencilState = gpu.dev.depthStencilState;
        auto rastState = gpu.dev.depthRasterizerState;

        fillPipeline = gpu.newPipeline(vertShaderFile, fragShaderFile, 0, 0, 1, 0, 1, 0, 1, 0, &rastState, &stencilState, &targetInfo);

        auto texturePath = context.app.userDir ~ "/container.bmp";

        import api.dm.back.sdl3.images.sdl_image : SdlImage;

        auto image = new SdlImage();
        if (const err = image.loadBMP(texturePath))
        {
            throw new Exception(err.toString);
        }

        if (image.getFormat != SDL_PIXELFORMAT_ABGR8888)
        {
            if (const err = image.convert(SDL_PIXELFORMAT_ABGR8888))
            {
                throw new Exception(err.toString);
            }
        }

        int w = image.getWidth;
        int h = image.getHeight;

        void* rawImagePtr;
        if (const err = image.getPixels(rawImagePtr))
        {
            throw new Exception(err.toString);
        }

        size_t imageLen = w * h * 4;

        ubyte[] imagePtr = (cast(ubyte*) rawImagePtr)[0 .. imageLen];

        SDL_GPUSamplerCreateInfo samplerInfo = gpu.dev.nearestRepeat;
        sampler = gpu.dev.newSampler(&samplerInfo);

        newTexture = gpu.dev.newTexture(w, h, SDL_GPU_TEXTURETYPE_2D, SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM, SDL_GPU_TEXTUREUSAGE_SAMPLER, 1, 1);

        SDL_SetGPUTextureName(gpu.dev.getObject, newTexture, "Test texture");

        auto transferBuffer2 = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);

        auto transBuffMap = gpu.dev.mapTransferBuffer(transferBuffer2, false);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        gpu.dev.unmapTransferBuffer(transferBuffer2);

        SDL_GPUTextureCreateInfo depthInfo;
        depthInfo.type = SDL_GPU_TEXTURETYPE_2D;
        depthInfo.width = cast(int) window.width;

        depthInfo.height = cast(int) window.height;
        depthInfo.layer_count_or_depth = 1;
        depthInfo.num_levels = 1;
        depthInfo.sample_count = SDL_GPU_SAMPLECOUNT_1;
        depthInfo.format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;
        depthInfo.usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET;

        sceneDepthTexture = gpu.dev.newTexture(&depthInfo);

        assert(gpu.dev.startCopyPass);

        cube.uploadStart;

        gpu.dev.uploadTexture(transferBuffer2, newTexture, w, h);

        assert(gpu.dev.endCopyPass);

        cube.uploadEnd;
        
        gpu.dev.deleteTransferBuffer(transferBuffer2);
    }

    float time;

    override void update(double dt)
    {
        super.update(dt);

        import api.math.matrices.affine3;

        cube.angle = cube.angle + 1;

        time = SDL_GetTicks / 1000.0;
    }

    override void draw()
    {
        super.draw;

        SDL_GPUDepthStencilTargetInfo depthStencilTargetInfo;
        depthStencilTargetInfo.texture = sceneDepthTexture;
        depthStencilTargetInfo.cycle = true;
        depthStencilTargetInfo.clear_depth = 1;
        depthStencilTargetInfo.clear_stencil = 0;
        depthStencilTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
        depthStencilTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
        depthStencilTargetInfo.stencil_load_op = SDL_GPU_LOADOP_CLEAR;
        depthStencilTargetInfo.stencil_store_op = SDL_GPU_STOREOP_STORE;

        assert(gpu.startRenderPass(&depthStencilTargetInfo));

        gpu.dev.bindPipeline(fillPipeline);

        Matrix4x4f[3] matrixBuff;
        matrixBuff[0] = cube.local;
        matrixBuff[1] = camera.view;
        matrixBuff[2] = camera.projection;

        //timeUniform.time = SDL_GetTicks() / 250.0;
        gpu.dev.pushUniformVertexData(0, matrixBuff.ptr, matrixBuff.sizeof);

        auto lightColor = RGBA.white;
        auto objectColor = RGBA.white;

        float[4] la = lightColor.toRGBArrayF;
        float[4] oa = objectColor.toRGBArrayF;

        float[8] planes = [
            10, 1000, la[0], la[1], la[2], oa[0], oa[1], oa[2]
        ];

        gpu.dev.pushUniformFragmentData(0, planes.ptr, planes.sizeof);

        cube.bindBuffers;
        gpu.dev.bindFragmentSamplers(newTexture, sampler);

        cube.drawIndexed;

        // gpu.dev.pushUniformVertexData(0, lmatrixBuff.ptr, lmatrixBuff.sizeof);
        // gpu.dev.pushUniformFragmentData(0, planes.ptr, planes.sizeof);
        // gpu.dev.drawIndexed(indices.length, 1, 0, 0, 0);

        assert(gpu.dev.endRenderPass);
    }

    override void dispose()
    {
        super.dispose;
        gpu.dev.deletePipeline(fillPipeline);
        gpu.dev.deleteTexture(newTexture);
        SDL_ReleaseGPUSampler(gpu.dev.getObject, sampler);
    }
}
