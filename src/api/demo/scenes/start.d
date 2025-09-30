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
    static SDL_GPUViewport SmallViewport = {160, 120, 320, 240, 0.1f, 1.0f};
    static SDL_Rect ScissorRect = {320, 240, 320, 240};

    static bool UseWireframeMode = false;
    static bool UseSmallViewport = false;
    static bool UseScissorRect = false;

    SdlGPUPipeline FillPipeline;
    SdlGPUPipeline LinePipeline;

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
        auto vertexText = cast(ubyte[]) vertShaderFile.read;

        auto vertexShader = _gpu.newVertexSPIRV(vertexText);

        auto fragShaderFile = context.app.userDir ~ "/shaders/SolidColor.frag.spv";
        auto fragText = cast(ubyte[]) fragShaderFile.read;

        auto fragmentShader = _gpu.newFragmentSPIRV(fragText, 0, 0, 1);

        SDL_GPUGraphicsPipelineCreateInfo info;
        info.target_info.num_color_targets = 1;

        import api.dm.com.com_native_ptr : ComNativePtr;

        ComNativePtr winNat;
        window.nativePtr(winNat);

        winPtr = winNat.castSafe!(SDL_Window*);

        auto format = SDL_GetGPUSwapchainTextureFormat(_gpu.getObject, winNat.castSafe!(
                SDL_Window*));

        SDL_GPUColorTargetDescription[] desc = [
            SDL_GPUColorTargetDescription(format)
        ];

        info.target_info.color_target_descriptions = desc.ptr;

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

        //info.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_FILL;

        SDL_GPUColorTargetDescription[1] colorTargetDescriptions;
        colorTargetDescriptions[0] = SDL_GPUColorTargetDescription();
        colorTargetDescriptions[0].blend_state.enable_blend = true;
        colorTargetDescriptions[0].blend_state.color_blend_op = SDL_GPU_BLENDOP_ADD;
        colorTargetDescriptions[0].blend_state.alpha_blend_op = SDL_GPU_BLENDOP_ADD;
        colorTargetDescriptions[0].blend_state.src_color_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA;
        colorTargetDescriptions[0].blend_state.dst_color_blendfactor = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        colorTargetDescriptions[0].blend_state.src_alpha_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA;
        colorTargetDescriptions[0].blend_state.dst_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        colorTargetDescriptions[0].format = SDL_GetGPUSwapchainTextureFormat(_gpu.getObject, winPtr);

        info.target_info.num_color_targets = 1;
        info.target_info.color_target_descriptions = colorTargetDescriptions.ptr;

        FillPipeline = _gpu.newPipeline(info);

        //info.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_LINE;

        LinePipeline = _gpu.newPipeline(info);

        _gpu.deleteShader(vertexShader);
        _gpu.deleteShader(fragmentShader);

        SDL_GPUBufferCreateInfo bufferInfo;
        bufferInfo.size = vertices.sizeof;
        bufferInfo.usage = SDL_GPU_BUFFERUSAGE_VERTEX;
        vertexBuffer = SDL_CreateGPUBuffer(_gpu.getObject, &bufferInfo);

        SDL_GPUTransferBufferCreateInfo transferInfo;
        transferInfo.size = vertices.sizeof;
        transferInfo.usage = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD;
        transferBuffer = SDL_CreateGPUTransferBuffer(_gpu.getObject, &transferInfo);

        Vertex* data = cast(Vertex*) SDL_MapGPUTransferBuffer(_gpu.getObject, transferBuffer, false);

        data[0] = vertices[0];
        data[1] = vertices[1];
        data[2] = vertices[2];

        // or you can copy them all in one operation
        // SDL_memcpy(data, vertices, sizeof(vertices));

        // unmap the pointer when you are done updating the transfer buffer
        SDL_UnmapGPUTransferBuffer(_gpu.getObject, transferBuffer);

        // start a copy pass
        SDL_GPUCommandBuffer* commandBuffer = SDL_AcquireGPUCommandBuffer(_gpu.getObject);
        SDL_GPUCopyPass* copyPass = SDL_BeginGPUCopyPass(commandBuffer);

        // where is the data
        SDL_GPUTransferBufferLocation location;
        location.transfer_buffer = transferBuffer;
        location.offset = 0;

        // where to upload the data
        SDL_GPUBufferRegion region;
        region.buffer = vertexBuffer;
        region.size = vertices.sizeof;
        region.offset = 0;

        // upload the data
        SDL_UploadToGPUBuffer(copyPass, &location, &region, true);

        // end the copy pass
        SDL_EndGPUCopyPass(copyPass);
        SDL_SubmitGPUCommandBuffer(commandBuffer);
        //SDL_ReleaseGPUTransferBuffer(context->Device, transferBuffer);

        //auto pipeline = gpuDevice.newVertexSPIRV(shaderText);

        //createDebugger;
    }

    override void update(double dt)
    {
        super.update(dt);
    }

    override void draw()
    {
        super.draw;
        gpu.bindPipeline(FillPipeline);

        timeUniform.time = SDL_GetTicksNS() / 1e9f;
        SDL_PushGPUFragmentUniformData(gpu.cmdBuff, 0, &timeUniform, UniformBuffer.sizeof);

        static SDL_GPUBufferBinding[1] bufferBindings;
        bufferBindings[0].buffer = vertexBuffer; // index 0 is slot 0 in this example
        bufferBindings[0].offset = 0; // start from the first byte

        SDL_BindGPUVertexBuffers(gpu.renderPass, 0, bufferBindings.ptr, 1); // bind one buffer starting from slot 0

        SDL_DrawGPUPrimitives(gpu.renderPass, 3, 1, 0, 0);

    }

    override void dispose()
    {
        super.dispose;
        _gpu.deletePipeline(FillPipeline);
        _gpu.deletePipeline(LinePipeline);

        SDL_ReleaseGPUBuffer(_gpu.getObject, vertexBuffer);
        SDL_ReleaseGPUTransferBuffer(_gpu.getObject, transferBuffer);
    }
}
