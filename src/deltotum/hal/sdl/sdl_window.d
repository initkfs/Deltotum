module deltotum.hal.sdl.sdl_window;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlWindow : SdlObjectWrapper!SDL_Window
{

    @property string title;

    private
    {
        int initialWidth;
        int initialHeight;
        double initialAspectRatio = 0;
    }

    this(string title,
        int x, int y, int w,
        int h, uint flags = SDL_WINDOW_RESIZABLE)
    {
        super();
        this.title = title;
        this.initialWidth = w;
        this.initialHeight = h;
        initialAspectRatio = initialWidth / initialHeight;

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

    void focus() @nogc nothrow
    {
        SDL_RaiseWindow(ptr);
    }

    SDL_Rect getScaleBounds() @nogc nothrow
    {
        int width, height;
        getSize(&width, &height);
    
        SDL_Rect bounds;
        if(width > initialWidth){
            const widthBar = (width - initialWidth) / 2;
            bounds.x = widthBar;
            bounds.w = width - widthBar;
        }

        if(height > initialHeight){
            const heightBar = (height - initialHeight) / 2;
            bounds.y = heightBar;
            bounds.h = height - heightBar;
        }

        return bounds;
    }

    void getSize(int* width, int* height) @nogc nothrow
    {
        SDL_GetWindowSize(ptr, width, height);
    }

    void getPos(int* x, int* y) @nogc nothrow
    {
        SDL_GetWindowPosition(ptr, x, y);
    }

    void move(int x, int y) @nogc nothrow
    {
        SDL_SetWindowPosition(ptr, x, y);
    }

    void resize(int width, int height) @nogc nothrow
    {
        SDL_SetWindowSize(ptr, width, height);
    }

    void setBordered(bool value) @nogc nothrow
    {
        const SDL_bool sdlValue = fromBool(value);
        SDL_SetWindowBordered(ptr, sdlValue);
    }

    void maximize() @nogc nothrow
    {
        SDL_MaximizeWindow(ptr);
    }

    void minimize() @nogc nothrow
    {
        SDL_MinimizeWindow(ptr);
    }

    void setTitle(string title) nothrow
    {
        SDL_SetWindowTitle(ptr, title.toStringz);
    }

    void setResizable(bool isResizable) @nogc nothrow
    {
        SDL_bool isSdlResizable = fromBool(isResizable);
        SDL_SetWindowResizable(ptr, isSdlResizable);
    }

    void restore() @nogc nothrow
    {
        SDL_RestoreWindow(ptr);
    }

    uint getId() @nogc nothrow
    {
        return SDL_GetWindowID(ptr);
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
