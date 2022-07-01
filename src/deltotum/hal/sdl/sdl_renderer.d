module deltotum.hal.sdl.sdl_renderer;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.sdl_window : SdlWindow;
import deltotum.hal.sdl.sdl_texture : SdlTexture;

import bindbc.sdl;

class SdlRenderer : SdlObjectWrapper!SDL_Renderer
{
    @property SdlWindow window;

    this(SDL_Renderer* ptr)
    {
        super(ptr);
    }

    this(SdlWindow window, int index = -1, uint flags = 0)
    {
        super();
        this.window = window;
        ptr = SDL_CreateRenderer(window.getStruct,
            index, flags);
        if (ptr is null)
        {
            string msg = "Cannot initialize renderer.";
            if (const err = getError)
            {
                msg ~= err;
            }
            throw new Exception(msg);
        }

    }

    bool setRenderDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) @nogc nothrow
    {
        int res = SDL_SetRenderDrawColor(ptr, r, g, b, a);
        return res == 0;
    }

    void clear() @nogc nothrow
    {
        SDL_RenderClear(ptr);
    }

    void present() @nogc nothrow
    {
        SDL_RenderPresent(ptr);
    }

    void copy(SdlTexture texture) @nogc nothrow
    {
        SDL_RenderCopy(ptr, texture.getStruct, null, null);
    }

    void drawRect(SDL_Rect* rect) @nogc nothrow
    {
        SDL_RenderDrawRect(ptr, rect);
    }

    void drawPoint(int x, int y) @nogc nothrow
    {
        SDL_RenderDrawPoint(ptr, x, y);
    }

    void drawLine(int startX, int startY, int endX, int endY) @nogc nothrow
    {
        SDL_RenderDrawLine(ptr, startX, startY, endX, endY);
    }

    void setViewport(SDL_Rect* rect) @nogc nothrow
    {
        SDL_RenderSetViewport(ptr, rect);
    }

    void fillRect(SDL_Rect* rect) @nogc nothrow
    {
        SDL_RenderFillRect(ptr, rect);
    }

    override void destroy()
    {
        SDL_DestroyRenderer(ptr);
        if (const err = getError)
        {
            throw new Exception("Unable to destroy renderer: " ~ err);
        }
    }
}
