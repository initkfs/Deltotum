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
import deltotum.window.window : Window;

import bindbc.sdl;

class MainController
{

    private
    {
        string windowTitle = "Hello, Deltotum.";
        AnimationBitmap animationBitmap;
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

        enum gameWidth = 320;
        enum gameHeight = 240;

        auto sdlWindow = new SdlWindow(windowTitle, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            gameWidth,
            gameHeight);
        auto sdlRenderer = new SdlRenderer(sdlWindow, SDL_RENDERER_ACCELERATED);
        window = new Window(sdlRenderer, sdlWindow);

        animationBitmap = new AnimationBitmap(window.renderer, 7);

        //TODO asset manager
        import std.file : thisExePath;
        import std.path : buildPath, dirName;

        string image = buildPath(thisExePath.dirName, "data/assets/anim-sprite.png");

        animationBitmap.load(image);
        animationBitmap.x = 100;
        animationBitmap.y = 100;

        import deltotum.input.mouse.event.mouse_event : MouseEvent;

        eventManager.onMouse = (e) {
            if (e.event == MouseEvent.Event.MOUSE_DOWN)
            {
                animationBitmap.velocity.x = 3;
                animationBitmap.acceleration.x = 0.4;
            }
        };

        application.onUpdate = (elapsedMs) {

            if (animationBitmap.velocity.x > 0 && animationBitmap.x >= gameWidth - animationBitmap.width)
            {
                animationBitmap.x = gameWidth - animationBitmap.width;
                animationBitmap.velocity.x = 0;
                animationBitmap.acceleration.x *= -1;
            }
            else if (animationBitmap.velocity.x < 0 && animationBitmap.x <= 0)
            {
                animationBitmap.x = 0;
                animationBitmap.velocity.x = 0;
                animationBitmap.acceleration.x *= -1;
            }

            window.renderer.clear;
            animationBitmap.draw;
            animationBitmap.update(elapsedMs);
            window.renderer.present;
        };

        application.runWait;

        application.clearErrors;

        animationBitmap.destroy;

        window.destroy;

        application.quit;
        return 0;
    }
}
