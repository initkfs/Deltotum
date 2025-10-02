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

import api.dm.kit.factories;

import std : writeln;

import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice, ComVertex;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.back.sdl3.gpu.sdl_gpu_shader : SdlGPUShader;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class Start : GuiScene
{

    SdlGPUPipeline fillPipeline;

    SDL_Window* winPtr;

    Random rnd;

    SdlGPUDevice _gpu;

    static ComVertex[3] vertices =
        [
            {-0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f}, // Bottom-left
            {0.5f, -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f}, // Bottom-right
            {0.0f, 0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.5f, 0.0f} // Top-center
    ];

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUTransferBuffer* transferBuffer;
    SDL_GPUTexture* newTexture;
    SDL_GPUSampler* sampler;

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

        import api.dm.gui.windows.gui_window : GuiWindow;

        _gpu = (cast(GuiWindow) window).gpuDevice;
        assert(_gpu);

        //TODO remove test
        import std.file : read;

        auto vertShaderFile = context.app.userDir ~ "/shaders/RawTriangle.vert.spv";
        auto fragShaderFile = context.app.userDir ~ "/shaders/SolidColor.frag.spv";

        auto texturePath = context.app.userDir ~ "/Lenna.png";

        import api.dm.back.sdl3.images.sdl_image : SdlImage;

        auto image = new SdlImage();
        if (const err = image.create(texturePath))
        {
            throw new Exception(err.toString);
        }

        import std;

        writeln(image.getWidth, " ", image.getHeight);

        if(const err = image.convert(SDL_PIXELFORMAT_RGBA8888)){
            throw new Exception(err.toString);
        }

        void* rawImagePtr;
        if (const err = image.getPixels(rawImagePtr))
        {
            throw new Exception(err.toString);
        }

        size_t imageLen = image.getWidth * image.getHeight * 4;

        ubyte[] imagePtr = (cast(ubyte*) rawImagePtr)[0 .. imageLen];

        fillPipeline = _gpu.newPipeline(window, vertShaderFile, fragShaderFile, 0, 0, 0, 0, 1, 0, 1, 0);

        _gpu.copyToNewGPUBuffer(vertices, false, vertexBuffer, transferBuffer);
        assert(vertexBuffer);

        gpu.uploadCopyGPUBuffer(transferBuffer, vertexBuffer, vertices.sizeof);
        _gpu.deleteTransferBuffer(transferBuffer);

        SDL_GPUSamplerCreateInfo samplerInfo;
        samplerInfo.min_filter = SDL_GPU_FILTER_LINEAR;
        samplerInfo.mag_filter = SDL_GPU_FILTER_LINEAR;
        samplerInfo.mipmap_mode = SDL_GPU_SAMPLERMIPMAPMODE_NEAREST;
        samplerInfo.address_mode_u = SDL_GPU_SAMPLERADDRESSMODE_REPEAT;
        samplerInfo.address_mode_v = SDL_GPU_SAMPLERADDRESSMODE_REPEAT;
        samplerInfo.address_mode_w = SDL_GPU_SAMPLERADDRESSMODE_REPEAT;
        samplerInfo.mip_lod_bias = 0;
        samplerInfo.max_anisotropy = 0;
        samplerInfo.min_lod = 0;
        samplerInfo.max_lod = 0;

        sampler = SDL_CreateGPUSampler(_gpu.getObject, &samplerInfo);

        newTexture = _gpu.newTexture(SDL_GPU_TEXTURETYPE_2D, SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM, SDL_GPU_TEXTUREUSAGE_SAMPLER, 512, 512, 1, 1);

        SDL_SetGPUTextureName(_gpu.getObject, newTexture, "Test texture");

        auto transferBuffer2 = _gpu.newTransferUploadBuffer(cast(uint) imageLen);

        auto transBuffMap = _gpu.mapTransferBuffer(transferBuffer2, true);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        _gpu.unmapTransferBuffer(transferBuffer2);

        SDL_GPUTextureTransferInfo source;
        //Direct3D 12
        //pixels_per_row align 256
        //offset align 512

        source.transfer_buffer = transferBuffer2;
        source.offset = 0;
        //source.pixels_per_row = 512;
        //source.rows_per_layer = 512;

        SDL_GPUTextureRegion dest;
        dest.texture = newTexture;
        dest.mip_level = 0;
        dest.x = 0;
        dest.y = 0;
        dest.z = 0;
        dest.w = 512;
        dest.h = 512;
        dest.d = 1;

        gpu.startCopyPass;
        gpu.uploadToTexture(&source, &dest, false);
        gpu.endCopyPass;

        //_gpu.deleteTransferBuffer(transferBuffer2);

        //createDebugger;
    }

    override void update(double dt)
    {
        super.update(dt);
    }

    override void draw()
    {
        super.draw;
        gpu.bindPipeline(fillPipeline);

        timeUniform.time = SDL_GetTicks() / 250.0;
        gpu.pushUniformFragmentData(0, &timeUniform, UniformBuffer.sizeof);

        static SDL_GPUBufferBinding[1] bufferBindings;
        bufferBindings[0].buffer = vertexBuffer;
        bufferBindings[0].offset = 0;

        gpu.bindVertexBuffer(0, bufferBindings);
        SDL_BindGPUVertexBuffers(gpu.renderPass, 0, bufferBindings.ptr, 1);

        static SDL_GPUTextureSamplerBinding sampleBinding;
        sampleBinding.texture = newTexture;
        assert(newTexture);
        sampleBinding.sampler = sampler;

        SDL_BindGPUFragmentSamplers(gpu.renderPass, 0, &sampleBinding, 1);

        gpu.draw(3, 1);
    }

    override void dispose()
    {
        super.dispose;
        _gpu.deletePipeline(fillPipeline);
        _gpu.deleteGPUBuffer(vertexBuffer);
        _gpu.deleteTexture(newTexture);
        SDL_ReleaseGPUSampler(_gpu.getObject, sampler);
    }
}
