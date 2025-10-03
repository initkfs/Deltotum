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

    static ComVertex[4] vertices =
        [
            {-1, 1, 0, 0, 0},
            {1, 1, 0, 4, 0},
            {1, -1, 0, 4, 4},
            {-1, -1, 0, 0, 4}
    ];

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUTransferBuffer* transferBuffer;
    SDL_GPUTexture* newTexture;
    SDL_GPUSampler* sampler;
    SDL_GPUBuffer* indexBuffer;

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

        //TODO remove test
        import std.file : read;

        auto vertShaderFile = context.app.userDir ~ "/Content/Shaders/Compiled/SPIRV/TexturedQuad.vert.spv";
        auto fragShaderFile = context.app.userDir ~ "/Content/Shaders/Compiled/SPIRV/TexturedQuad.frag.spv";

        fillPipeline = gpu.newPipeline(vertShaderFile, fragShaderFile, 0, 0, 0, 0, 1, 0, 0, 0);


        auto texturePath = context.app.userDir ~ "/Content/Images/ravioli.bmp";

        import api.dm.back.sdl3.images.sdl_image : SdlImage;

        auto image = new SdlImage();
        if (const err = image.loadBMP(texturePath))
        {
            throw new Exception(err.toString);
        }
        
        if (const err = image.convert(SDL_PIXELFORMAT_RGBA8888))
        {
            throw new Exception(err.toString);
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

        uint len = cast(uint)(vertices.length * ComVertex.sizeof + ushort.sizeof * 6);

        vertexBuffer = gpu.dev.newGPUBufferVertex(vertices.length * ComVertex.sizeof);

        transferBuffer = gpu.dev.newTransferUploadBuffer(len);

        ubyte * ptr = cast(ubyte*) gpu.dev.mapTransferBuffer(transferBuffer, false);

        ComVertex[] data = (cast(ComVertex*) ptr)[0 .. (
                vertices.length)];

        data[0 .. vertices.length] = vertices[];

        ushort[] indexData = (cast(ushort*) &ptr[ComVertex.sizeof * 4])[0 .. 6];
        indexData[0] = 0;
        indexData[1] = 1;
        indexData[2] = 2;
        indexData[3] = 0;
        indexData[4] = 2;
        indexData[5] = 3;

        indexBuffer = gpu.dev.newGPUBufferIndex(ushort.sizeof * 6);

         SDL_GPUSamplerCreateInfo samplerInfo;
        samplerInfo.min_filter = SDL_GPU_FILTER_NEAREST,
		samplerInfo.mag_filter = SDL_GPU_FILTER_NEAREST,
		samplerInfo.mipmap_mode = SDL_GPU_SAMPLERMIPMAPMODE_NEAREST,
		samplerInfo.address_mode_u = SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
		samplerInfo.address_mode_v = SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
		samplerInfo.address_mode_w = SDL_GPU_SAMPLERADDRESSMODE_REPEAT,

        sampler = SDL_CreateGPUSampler(gpu.dev.getObject, &samplerInfo);

        newTexture = gpu.dev.newTexture(SDL_GPU_TEXTURETYPE_2D, SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM, SDL_GPU_TEXTUREUSAGE_SAMPLER, w, h, 1, 1);

        SDL_SetGPUTextureName(gpu.dev.getObject, newTexture, "Test texture");

        auto transferBuffer2 = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);

        auto transBuffMap = gpu.dev.mapTransferBuffer(transferBuffer2, false);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        gpu.dev.unmapTransferBuffer(transferBuffer2);

        assert(gpu.dev.startCopyPass);

        gpu.dev.unmapAndUpload(transferBuffer, vertexBuffer, ComVertex.sizeof * 4, 0, 0, false);
        gpu.dev.unmapAndUpload(transferBuffer, indexBuffer, ushort.sizeof * 6, ComVertex.sizeof * 4, 0, false);

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
        dest.w = w;
        dest.h = h;
        dest.d = 1;

        gpu.dev.uploadTexture(&source, &dest, false);
        
        assert(gpu.dev.endCopyPass);

        //_gpu.dev.deleteTransferBuffer(transferBuffer);
        //_gpu.dev.deleteTransferBuffer(transferBuffer2);

        //createDebugger;
    }

    override void update(double dt)
    {
        super.update(dt);
    }

    override void draw()
    {
        super.draw;

        assert(gpu.startRenderPass);

        gpu.dev.bindPipeline(fillPipeline);

        //timeUniform.time = SDL_GetTicks() / 250.0;
        //gpu.dev.pushUniformFragmentData(0, &timeUniform, UniformBuffer.sizeof);

        SDL_GPUBufferBinding[1] bufferBindings;
        bufferBindings[0].buffer = vertexBuffer;
        bufferBindings[0].offset = 0;

        gpu.dev.bindVertexBuffer(0, bufferBindings);
        SDL_BindGPUVertexBuffers(gpu.dev.renderPass, 0, bufferBindings.ptr, 1);

        SDL_GPUTextureSamplerBinding sampleBinding;
        sampleBinding.texture = newTexture;
        assert(newTexture);
        sampleBinding.sampler = sampler;

        SDL_GPUBufferBinding indexBinding;
        indexBinding.buffer = indexBuffer;
        indexBinding.offset = 0;

        SDL_BindGPUIndexBuffer(gpu.dev. renderPass, &indexBinding, SDL_GPU_INDEXELEMENTSIZE_16BIT);

        SDL_BindGPUFragmentSamplers(gpu.dev.renderPass, 0, &sampleBinding, 1);

        //gpu.dev.draw(3, 1);
        SDL_DrawGPUIndexedPrimitives(gpu.dev.renderPass, 6, 1, 0, 0, 0);

        assert(gpu.dev.endRenderPass);
    }

    override void dispose()
    {
        super.dispose;
        gpu.dev.deletePipeline(fillPipeline);
        gpu.dev.deleteGPUBuffer(vertexBuffer);
        gpu.dev.deleteTexture(newTexture);
        SDL_ReleaseGPUSampler(gpu.dev.getObject, sampler);
    }
}
