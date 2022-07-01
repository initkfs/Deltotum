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

    int setRenderDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_SetRenderDrawColor(ptr, r, g, b, a);
        return zeroOrErrorCode;
    }

    int clear() @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderClear(ptr);
        return zeroOrErrorCode;
    }

    void present() @nogc nothrow
    {
        SDL_RenderPresent(ptr);
    }

    int copy(SdlTexture texture) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderCopy(ptr, texture.getStruct, null, null);
        return zeroOrErrorCode;
    }

    int drawRect(SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawRect(ptr, rect);
        return zeroOrErrorCode;
    }

    int drawPoint(int x, int y) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawPoint(ptr, x, y);
        return zeroOrErrorCode;
    }

    int drawLine(int startX, int startY, int endX, int endY) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawLine(ptr, startX, startY, endX, endY);
        return zeroOrErrorCode;
    }

    int setViewport(SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderSetViewport(ptr, rect);
        return zeroOrErrorCode;
    }

    int fillRect(SDL_Rect* rect) @nogc nothrow
    {
         const int zeroOrErrorCode = SDL_RenderFillRect(ptr, rect);
         return zeroOrErrorCode;
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
