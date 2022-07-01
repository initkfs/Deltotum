module game.main_controller;

import std.stdio : writeln;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.sdl_window : SdlWindow;
import deltotum.hal.sdl.sdl_surface : SdlSurface;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;
import deltotum.hal.sdl.img.sdl_img_lib : SdlImgLib;
import deltotum.display.bitmap.animation_bitmap: AnimationBitmap;

;

import bindbc.sdl;

class MainController
{

    private
    {
        SdlLib sdlLib;
        string windowTitle = "Hello, Deltotum.";
        SdlWindow window;
        SdlRenderer renderer;
        SdlImgLib imageLib;
        AnimationBitmap animationBitmap;
        bool running = true;
        
    }

    int run()
    {

        sdlLib = new SdlLib;
        sdlLib.initialize;
        writeln(sdlLib.getSdlVersionInfo);

        imageLib = new SdlImgLib;
        imageLib.initialize;

        window = new SdlWindow(windowTitle, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640,
            480);
        renderer = new SdlRenderer(window, SDL_RENDERER_ACCELERATED);

        animationBitmap = new AnimationBitmap(renderer, 7);

        //TODO asset manager
        import std.file: thisExePath;
        import std.path: buildPath, dirName;

        string image = buildPath(thisExePath.dirName, "data/assets/space/asteroids/asteroid.png"); 

        animationBitmap.load(image);
        animationBitmap.x = 100;
        animationBitmap.y = 100;

        while (running)
        {
            SDL_Event event;
            //TODO while loop for events
            if (SDL_PollEvent(&event))
            {
                switch (event.type)
                {
                case SDL_QUIT:
                    running = false;
                    break;
                default:
                    break;
                }
            }

            renderer.clear;
            animationBitmap.draw;
            animationBitmap.update;
            renderer.present;
        }

        animationBitmap.destroy;
        renderer.destroy;
        sdlLib.clearError;
        window.destroy;
        imageLib.quit;
        sdlLib.quit;
        return 0;
    }
}
