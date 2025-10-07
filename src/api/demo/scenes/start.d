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
        // Front face (Z = 0.5)
        ComVertex(-0.5f, -0.5f, 0.5f, 0.0f, 1.0f), // 0: left bottom
        ComVertex(0.5f, -0.5f, 0.5f, 1.0f, 1.0f), // 1: bottom right
        ComVertex(0.5f, 0.5f, 0.5f, 1.0f, 0.0f), // 2: top right
        ComVertex(-0.5f, 0.5f, 0.5f, 0.0f, 0.0f), // 3: top left

        //back face (Z = -0.5) 
        ComVertex(0.5f, -0.5f, -0.5f, 0.0f, 1.0f), // 4: bottom right
        ComVertex(-0.5f, -0.5f, -0.5f, 1.0f, 1.0f), // 5: bottom left
        ComVertex(-0.5f, 0.5f, -0.5f, 1.0f, 0.0f), // 6: top left
        ComVertex(0.5f, 0.5f, -0.5f, 0.0f, 0.0f), // 7: top right

        // Left face (X = -0.5)
        ComVertex(-0.5f, -0.5f, -0.5f, 0.0f, 1.0f), // 8: bottom back
        ComVertex(-0.5f, -0.5f, 0.5f, 1.0f, 1.0f), // 9: bottom front
        ComVertex(-0.5f, 0.5f, 0.5f, 1.0f, 0.0f), // 10: top front
        ComVertex(-0.5f, 0.5f, -0.5f, 0.0f, 0.0f), // 11: top back

        // Right face (X = 0.5)
        ComVertex(0.5f, -0.5f, 0.5f, 0.0f, 1.0f), // 12: bottom front
        ComVertex(0.5f, -0.5f, -0.5f, 1.0f, 1.0f), // 13: bottom back
        ComVertex(0.5f, 0.5f, -0.5f, 1.0f, 0.0f), // 14: top back
        ComVertex(0.5f, 0.5f, 0.5f, 0.0f, 0.0f), // 15: top front

        // Top face (Y = 0.5)
        ComVertex(-0.5f, 0.5f, 0.5f, 0.0f, 1.0f), // 16: front left
        ComVertex(0.5f, 0.5f, 0.5f, 1.0f, 1.0f), // 17: front right
        ComVertex(0.5f, 0.5f, -0.5f, 1.0f, 0.0f), // 18: back rigth
        ComVertex(-0.5f, 0.5f, -0.5f, 0.0f, 0.0f), // 19: back left

        // Bottom face (Y = -0.5)
        ComVertex(-0.5f, -0.5f, -0.5f, 0.0f, 1.0f), // 20: back left
        ComVertex(0.5f, -0.5f, -0.5f, 1.0f, 1.0f), // 21: back right
        ComVertex(0.5f, -0.5f, 0.5f, 1.0f, 0.0f), // 22: front right
        ComVertex(-0.5f, -0.5f, 0.5f, 0.0f, 0.0f) // 23: front left
    ];

    //ccw
    ushort[] indices = [
        // front face
        0, 1, 2, 0, 2, 3,
        // back face
        4, 5, 6, 4, 6, 7,
        //left face
        8, 9, 10, 8, 10, 11,
        // right face
        12, 13, 14, 12, 14, 15,
        //top face
        16, 17, 18, 16, 18, 19,
        // bottom face
        20, 21, 22, 20, 22, 23
    ];

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUTransferBuffer* transferBuffer;
    SDL_GPUTexture* newTexture;
    SDL_GPUSampler* sampler;
    SDL_GPUBuffer* indexBuffer;

    SDL_GPUTexture* sceneDepthTexture;

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

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM;
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

        SDL_GPUTextureCreateInfo depthInfo;
        depthInfo.type = SDL_GPU_TEXTURETYPE_2D;
        depthInfo.width = cast(int) window.width;
        ;
        depthInfo.height = cast(int) window.height;
        depthInfo.layer_count_or_depth = 1;
        depthInfo.num_levels = 1;
        depthInfo.sample_count = SDL_GPU_SAMPLECOUNT_1;
        depthInfo.format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;
        depthInfo.usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET;

        sceneDepthTexture = gpu.dev.newTexture(&depthInfo);

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

        import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;
    }

    float angle = 9;

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

        //timeUniform.time = SDL_GetTicks() / 250.0;
        gpu.dev.pushUniformVertexData(0, matrixBuff.ptr, matrixBuff.sizeof);

        float[2] planes = [10, 60];

        gpu.dev.pushUniformFragmentData(0, planes.ptr, planes.sizeof);

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
