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

import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
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
    
    struct Vertex
    {
        align(1):
        float x = 0, y  = 0, z  = 0; //vec3 position
        float r  = 0, g = 0, b = 0, a = 0; //vec4 color
    }

    // a list of vertices
    static Vertex[3] vertices =
        [
            Vertex(0.0f, 0.5f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f), // top vertex
            Vertex(-0.5f, -0.5f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f), // bottom left vertex
            Vertex(0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f) // bottom right vertex
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
        auto vertexShader = _gpu.newVertexSPIRV(vertShaderFile);

        auto fragShaderFile = context.app.userDir ~ "/shaders/SolidColor.frag.spv";
        auto fragmentShader = _gpu.newFragmentSPIRV(fragShaderFile, 0, 0, 1);

        SDL_GPUGraphicsPipelineCreateInfo info;

        info.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;
        info.vertex_shader = vertexShader.getObject;
        info.fragment_shader = fragmentShader.getObject;

        SDL_GPUVertexBufferDescription[1] vertexBufferDesctiptions;
        vertexBufferDesctiptions[0].slot = 0;
        vertexBufferDesctiptions[0].input_rate = SDL_GPU_VERTEXINPUTRATE_VERTEX;
        vertexBufferDesctiptions[0].instance_step_rate = 0;
        vertexBufferDesctiptions[0].pitch = Vertex.sizeof;

        info.vertex_input_state.num_vertex_buffers = 1;
        info.vertex_input_state.vertex_buffer_descriptions = vertexBufferDesctiptions.ptr;

        SDL_GPUVertexAttribute[2] vertexAttributes;

        // a_position
        vertexAttributes[0].buffer_slot = 0; // fetch data from the buffer at slot 0
        vertexAttributes[0].location = 0; // layout (location = 0) in shader
        vertexAttributes[0].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3; //vec3
        vertexAttributes[0].offset = 0; // start from the first byte from current buffer position

        // a_color
        vertexAttributes[1].buffer_slot = 0; // use buffer at slot 0
        vertexAttributes[1].location = 1; // layout (location = 1) in shader
        vertexAttributes[1].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4; //vec4
        vertexAttributes[1].offset = float.sizeof * 3; // 4th float from current buffer position

        info.vertex_input_state.num_vertex_attributes = 2;
        info.vertex_input_state.vertex_attributes = vertexAttributes.ptr;

        SDL_GPUColorTargetDescription[1] colorTargetDescriptions = gpu.blendingAlpha(window);
        info.target_info.num_color_targets = colorTargetDescriptions.length;
        info.target_info.color_target_descriptions = colorTargetDescriptions.ptr;

        fillPipeline = _gpu.newPipeline(info);

        _gpu.deleteShader(vertexShader);
        _gpu.deleteShader(fragmentShader);

        vertexBuffer = _gpu.newGPUBufferVertex(vertices.sizeof);
        transferBuffer = _gpu.newTransferUploadBuffer(vertices.sizeof);

        Vertex* data = cast(Vertex*) _gpu.mapTransferBuffer(transferBuffer, false);

        data[0] = vertices[0];
        data[1] = vertices[1];
        data[2] = vertices[2];        

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
        _gpu.deletePipeline(LinePipeline);
        _gpu.deleteGPUBuffer(vertexBuffer);
    }
}
