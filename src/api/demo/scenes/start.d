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

        auto fragmentShader = _gpu.newFragmentSPIRV(fragText);

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

        info.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_FILL;

        FillPipeline = _gpu.newPipeline(info);

        info.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_LINE;

        LinePipeline = _gpu.newPipeline(info);

        _gpu.deleteShader(vertexShader);
        _gpu.deleteShader(fragmentShader);

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
        gpu.bindPipeline( FillPipeline);
        gpu.draw(3, 1, 0, 0);
    }

    override void dispose()
    {
        super.dispose;
        _gpu.deletePipeline(FillPipeline);
        _gpu.deletePipeline(LinePipeline);
    }
}
