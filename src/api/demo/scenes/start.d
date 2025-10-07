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

import api.math.matrices.matrix;

/**
 * Authors: initkfs
 */
class Start : GuiScene
{

    SdlGPUPipeline fillPipeline;

    SDL_Window* winPtr;

    Random rnd;

    ComVertex[] vertices = [
        ComVertex(-0.5f, -0.5f, 0.5f, 0.0f, 1.0f), 
        ComVertex(0.5f, -0.5f, 0.5f, 1.0f, 1.0f), 
        ComVertex(0.5f, 0.5f, 0.5f, 1.0f, 0.0f),
        ComVertex(-0.5f, 0.5f, 0.5f, 0.0f, 0.0f),
        ComVertex(0.5f, -0.5f, -0.5f, 0.0f, 1.0f),
        ComVertex(-0.5f, -0.5f, -0.5f, 1.0f, 1.0f),
        ComVertex(-0.5f, 0.5f, -0.5f, 1.0f, 0.0f),
        ComVertex(0.5f, 0.5f, -0.5f, 0.0f, 0.0f), 
        ComVertex(-0.5f, -0.5f, -0.5f, 0.0f, 1.0f),
        ComVertex(-0.5f, -0.5f, 0.5f, 1.0f, 1.0f),
        ComVertex(-0.5f, 0.5f, 0.5f, 1.0f, 0.0f),
        ComVertex(-0.5f, 0.5f, -0.5f, 0.0f, 0.0f), 
        ComVertex(0.5f, -0.5f, 0.5f, 0.0f, 1.0f),
        ComVertex(0.5f, -0.5f, -0.5f, 1.0f, 1.0f),
        ComVertex(0.5f, 0.5f, -0.5f, 1.0f, 0.0f),
        ComVertex(0.5f, 0.5f, 0.5f, 0.0f, 0.0f),
    ];
    ushort[] indices = [

        0, 1, 2, 0, 2, 3, 
        4, 5, 6, 4, 6, 7, 
        8, 9, 10, 8, 10, 11,
        12, 13, 14, 12, 14, 15
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

    align(16)
    {
        Matrix4x4f transform;

        Matrix4x4f model;
        Matrix4x4f view;
        Matrix4x4f projection;
    }

    Matrix4x4f[3] matrixBuff;

    override void create()
    {
        super.create;
        rnd = new Random;

        import api.dm.gui.windows.gui_window : GuiWindow;

        //TODO remove test
        import std.file : read;

        auto vertShaderFile = context.app.userDir ~ "/shaders/TexturedBox.vert.spv";
        auto fragShaderFile = context.app.userDir ~ "/shaders/TexturedBox.frag.spv";

        fillPipeline = gpu.newPipeline(vertShaderFile, fragShaderFile, 0, 0, 1, 0, 1, 0, 0, 0);

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

        uint len = cast(uint)(vertices.length * ComVertex.sizeof + ushort.sizeof * indices.length);

        vertexBuffer = gpu.dev.newGPUBufferVertex(vertices.length * ComVertex.sizeof);

        transferBuffer = gpu.dev.newTransferUploadBuffer(len);

        gpu.dev.copyToBuffer(transferBuffer, false, vertices, indices);

        indexBuffer = gpu.dev.newGPUBufferIndex(ushort.sizeof * indices.length);

        SDL_GPUSamplerCreateInfo samplerInfo = gpu.dev.nearestRepeat;
        sampler = gpu.dev.newSampler(&samplerInfo);

        newTexture = gpu.dev.newTexture(w, h, SDL_GPU_TEXTURETYPE_2D, SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM, SDL_GPU_TEXTUREUSAGE_SAMPLER, 1, 1);

        SDL_SetGPUTextureName(gpu.dev.getObject, newTexture, "Test texture");

        auto transferBuffer2 = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);

        auto transBuffMap = gpu.dev.mapTransferBuffer(transferBuffer2, false);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        gpu.dev.unmapTransferBuffer(transferBuffer2);

        assert(gpu.dev.startCopyPass);

        gpu.dev.unmapAndUpload(transferBuffer, vertexBuffer, ComVertex.sizeof * vertices.length, 0, 0, false);
        gpu.dev.unmapAndUpload(transferBuffer, indexBuffer, ushort.sizeof * indices.length, ComVertex.sizeof * vertices
                .length, 0, false);

        gpu.dev.uploadTexture(transferBuffer2, newTexture, w, h);

        assert(gpu.dev.endCopyPass);

        gpu.dev.deleteTransferBuffer(transferBuffer);
        gpu.dev.deleteTransferBuffer(transferBuffer2);

        transform.fillInit;

        import api.math.matrices.affine3;

        model = rotateMatrix(-55, 1.0f, 0.0f, 0.0f);
        view = translateMatrix(0.0f, 0.0f, 3.0f);

        import api.math.geom2.vec3;

        view = lookAt(
            Vec3f(0, 0, -3), 
            Vec3f(0, 0, 0),
            Vec3f(0, 1, 0)
            
        );

        projection = perspectiveMatrix(45.0f, window.width / window.height, 0.1f, 100.0f);
        transform = projection;

        matrixBuff[0] = model;
        matrixBuff[1] = view;
        matrixBuff[2] = projection;
        //createDebugger;

        import api.dm.kit.sprites2d.tweens.pause_tween2d: PauseTween2d;
    }

    float angle  = 9;

    override void update(double dt)
    {
        super.update(dt);

        import api.math.matrices.affine3;

        model = rotateMatrix((angle = (angle + 1)) % 360, 1.0f, 1.0f, 0.0f);

        matrixBuff[0] = model;
        matrixBuff[1] = view;
        matrixBuff[2] = projection;
    }

    override void draw()
    {
        super.draw;

        assert(gpu.startRenderPass);

        gpu.dev.bindPipeline(fillPipeline);

        //timeUniform.time = SDL_GetTicks() / 250.0;
        gpu.dev.pushUniformFragmentData(0, matrixBuff.ptr, matrixBuff.sizeof);

        gpu.dev.bindVertexBuffer(vertexBuffer);
        gpu.dev.bindIndexBuffer(indexBuffer);
        gpu.dev.bindFragmentSamplers(newTexture, sampler);

        //gpu.dev.draw(3, 1);
        gpu.dev.drawIndexed(indices.length, 1, 0, 0, 0);

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
