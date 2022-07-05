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

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class MainController : UniComponent
{

    private
    {
        string windowTitle = "Hello, Deltotum.";
        Bitmap sprite;
        bool running = true;
        SdlApplication application;
        Window window;

    }

    int run()
    {
        auto eventManager = new SdlEventManager;
        eventManager.onApplication = (event) { writeln(event); };

        application = new SdlApplication(new SdlLib, new SdlImgLib, eventManager);
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
        window = new Window(sdlRenderer, sdlWindow);

        //sprite = new AnimationBitmap(window.renderer, 7);
        sprite = new Bitmap(window.renderer);
        build(sprite);

        bool isLoad = sprite.load("sprite.png");
        if (!isLoad)
        {
            logger.error("Unable to load test sprite");
        }
        sprite.x = 100;
        sprite.y = 100;
        sprite.draw;

        import deltotum.input.mouse.event.mouse_event : MouseEvent;

        eventManager.onMouse = (e) {
            if (e.event == MouseEvent.Event.MOUSE_DOWN)
            {
                sprite.velocity.x = 500;
                sprite.acceleration.x = 500;
            }
        };

        application.onUpdate = (elapsedMs) {

            if (sprite.velocity.x > 0 && sprite.x >= gameWidth - sprite.width)
            {
                sprite.x = gameWidth - sprite.width;
                sprite.velocity.x = 0;
                sprite.acceleration.x *= -1;
            }
            else if (sprite.velocity.x < 0 && sprite.x <= 0)
            {
                sprite.x = 0;
                sprite.velocity.x = 0;
                sprite.acceleration.x *= -1;
            }

            window.renderer.clear;
            sprite.draw;
            sprite.update(elapsedMs);
            window.renderer.present;
        };

        application.runWait;

        application.clearErrors;

        sprite.destroy;

        window.destroy;

        application.quit;
        return 0;
    }
}
