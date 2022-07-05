module game.main_controller;

import deltotum.asset.asset_manager : AssetManager;

import std.experimental.logger : Logger;

import std.stdio : writeln;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.sdl_window : SdlWindow;
import deltotum.hal.sdl.sdl_surface : SdlSurface;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.display.bitmap.animation_bitmap : AnimationBitmap;
import deltotum.application.sdl.sdl_application : SdlApplication;
import deltotum.event.sdl.sdl_event_manager : SdlEventManager;
import deltotum.window.window : Window;
import deltotum.application.components.uni.uni_component : UniComponent;
import game.state.demo_state: DemoState;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class MainController : UniComponent
{

    private
    {
        string windowTitle = "Hello, Deltotum.";
        SdlApplication application;
    }

    int run()
    {
        application = new SdlApplication(new SdlLib, new SdlImgLib);
        application.initialize;

        //TODO move to state
        this.logger = application.logger;
        this.assets = application.assets;

        enum gameWidth = 640;
        enum gameHeight = 480;

        auto sdlWindow = new SdlWindow(windowTitle, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            gameWidth,
            gameHeight);
        auto sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED);
        application.window = new Window(sdlRenderer, sdlWindow);

        auto gameState = new DemoState;
        application.addState(gameState);

        application.runWait;

        application.quit;
        return 0;
    }
}
