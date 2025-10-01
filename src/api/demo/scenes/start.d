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
            ComVertex(0.0f, 0.5f, 0.0f, 1.0f), // top vertex
            ComVertex(-0.5f, -0.5f, 0.0f, 1.0f, 1.0f), // bottom left vertex
            ComVertex(0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 1.0f) // bottom right vertex
    ];

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUTransferBuffer* transferBuffer;

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

        fillPipeline = _gpu.newPipeline(window, vertShaderFile, fragShaderFile, 0, 0, 0, 0, 0, 0, 1);

        _gpu.copyToNewGPUBuffer(vertices, false, vertexBuffer, transferBuffer);
        assert(vertexBuffer);        

        gpu.uploadCopyGPUBuffer(transferBuffer, vertexBuffer, vertices.sizeof);
        _gpu.deleteTransferBuffer(transferBuffer);

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

        timeUniform.time = SDL_GetTicksNS() / 1e9f;
        gpu.pushUniformFragmentData(0,  &timeUniform, UniformBuffer.sizeof);

        static SDL_GPUBufferBinding[1] bufferBindings;
        bufferBindings[0].buffer = vertexBuffer;
        bufferBindings[0].offset = 0;

        gpu.bindVertexBuffer(0, bufferBindings);
        SDL_BindGPUVertexBuffers(gpu.renderPass, 0, bufferBindings.ptr, 1);
        gpu.draw(3, 1);
    }

    override void dispose()
    {
        super.dispose;
        _gpu.deletePipeline(fillPipeline);
        _gpu.deleteGPUBuffer(vertexBuffer);
    }
}
