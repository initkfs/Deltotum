module game.main_controller;

import std.stdio : writeln;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.sdl_window : SdlWindow;
import deltotum.hal.sdl.sdl_surface : SdlSurface;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.display.bitmap.animation_bitmap : AnimationBitmap;
import deltotum.application.sdl.sdl_application : SdlApplication;
import deltotum.event.sdl.sdl_event_manager : SdlEventManager;

import bindbc.sdl;

class MainController
{

    private
    {
        string windowTitle = "Hello, Deltotum.";
        SdlWindow window;
        SdlRenderer renderer;
        AnimationBitmap animationBitmap;
        bool running = true;
        SdlApplication application;
    }

    int run()
    {
        auto eventManager = new SdlEventManager;
        eventManager.onApplication = (event) { writeln(event); };

        application = new SdlApplication(new SdlLib, new SdlImgLib, eventManager);
        application.initialize;

        window = new SdlWindow(windowTitle, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640,
            480);
        renderer = new SdlRenderer(window, SDL_RENDERER_ACCELERATED);

        animationBitmap = new AnimationBitmap(renderer, 7);

        //TODO asset manager
        import std.file : thisExePath;
        import std.path : buildPath, dirName;

        string image = buildPath(thisExePath.dirName, "data/assets/space/asteroids/asteroid.png");

        animationBitmap.load(image);
        animationBitmap.x = 100;
        animationBitmap.y = 100;

        application.onUpdate = (elapsedMs) {
            renderer.clear;
            animationBitmap.draw;
            animationBitmap.update;
            renderer.present;
        };

        application.runWait;

        application.clearErrors;

        animationBitmap.destroy;
        renderer.destroy;
        window.destroy;

        application.quit;
        return 0;
    }
}
