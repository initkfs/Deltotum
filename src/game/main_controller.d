module game.main_controller;

import std.stdio : writeln;

import deltotum.hal.sdl.sdl_lib : SdlLib;
import deltotum.hal.sdl.sdl_window : SdlWindow;

import bindbc.sdl;

class MainController
{

    private
    {
        SdlLib sdlLib;
        string windowTitle = "Hello, Deltotum.";
        SdlWindow window;

    }

    int run()
    {

        sdlLib = new SdlLib;
        sdlLib.initialize;

        window = new SdlWindow(windowTitle, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640,
            480);

        sdlLib.clearError;
        window.destroy;
        sdlLib.quit;
        return 0;
    }
}
