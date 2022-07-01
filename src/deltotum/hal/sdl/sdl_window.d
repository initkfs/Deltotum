module deltotum.hal.sdl.sdl_window;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

class SdlWindow : SdlObjectWrapper!SDL_Window
{

    @property string title;

    this(string title,
        int x, int y, int w,
        int h, uint flags = SDL_WINDOW_RESIZABLE)
    {
        super();
        this.title = title;

        ptr = SDL_CreateWindow(title.toStringz,
            x, y, w,
            h, flags);
        if (ptr is null)
        {
            string msg = getError;
            throw new Exception("Unable to initialize SDL window: " ~ msg);
        }

    }

    this(SDL_Window* ptr)
    {
        super(ptr);
    }

    override void destroy()
    {
        SDL_DestroyWindow(ptr);
        if (auto err = getError)
        {
            throw new Exception("Unable to destroy SDL window: " ~ err);
        }
    }

}
