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

        uint len = cast(uint)(vertices.length * ComVertex.sizeof + ushort.sizeof * 6);

        vertexBuffer = gpu.dev.newGPUBufferVertex(vertices.length * ComVertex.sizeof);

        transferBuffer = gpu.dev.newTransferUploadBuffer(len);

        ushort[] idx = [0, 1, 2, 0, 2, 3];
        gpu.dev.copyToBuffer(transferBuffer, false, vertices, idx);

        indexBuffer = gpu.dev.newGPUBufferIndex(ushort.sizeof * 6);

        SDL_GPUSamplerCreateInfo samplerInfo = gpu.dev.nearestRepeat;
        sampler = gpu.dev.newSampler(&samplerInfo);

        newTexture = gpu.dev.newTexture( w, h, SDL_GPU_TEXTURETYPE_2D, SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM, SDL_GPU_TEXTUREUSAGE_SAMPLER, 1, 1);

        SDL_SetGPUTextureName(gpu.dev.getObject, newTexture, "Test texture");

        auto transferBuffer2 = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);

        auto transBuffMap = gpu.dev.mapTransferBuffer(transferBuffer2, false);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        gpu.dev.unmapTransferBuffer(transferBuffer2);

        assert(gpu.dev.startCopyPass);

        gpu.dev.unmapAndUpload(transferBuffer, vertexBuffer, ComVertex.sizeof * 4, 0, 0, false);
        gpu.dev.unmapAndUpload(transferBuffer, indexBuffer, ushort.sizeof * 6, ComVertex.sizeof * 4, 0, false);

        gpu.dev.uploadTexture(transferBuffer2, newTexture, w, h);

        assert(gpu.dev.endCopyPass);

        gpu.dev.deleteTransferBuffer(transferBuffer);
        gpu.dev.deleteTransferBuffer(transferBuffer2);

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

        gpu.dev.bindVertexBuffer(vertexBuffer);
        gpu.dev.bindIndexBuffer(indexBuffer);
        gpu.dev.bindFragmentSamplers(newTexture, sampler);

        //gpu.dev.draw(3, 1);
        gpu.dev.drawIndexed(6, 1, 0, 0, 0);

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
