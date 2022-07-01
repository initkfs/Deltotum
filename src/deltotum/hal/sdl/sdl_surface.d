module deltotum.hal.sdl.sdl_surface;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.sdl_window : SdlWindow;

import bindbc.sdl;

class SdlSurface : SdlObjectWrapper!SDL_Surface
{
    this(SDL_Surface* ptr)
    {
        super(ptr);
    }

    static SdlSurface getWindowSurface(SdlWindow window)
    {
        SDL_Surface* ptr = SDL_GetWindowSurface(window.getStruct);
        return new SdlSurface(ptr);
    }

    SDL_Surface* convertSurfacePtr(SDL_Surface* src, SDL_PixelFormat* format, uint flags = 0) const @nogc nothrow
    {
        SDL_Surface* ptr = SDL_ConvertSurface(src, format, flags);
        return ptr;
    }

    void scaleTo(SdlSurface dest, SDL_Rect* bounds) @nogc nothrow
    {
        SDL_BlitScaled(ptr, null, dest.getStruct, bounds);
    }

    SDL_PixelFormat* getPixelFormat() @nogc nothrow @safe
    {
        return ptr.format;
    }

    override void destroy() @nogc nothrow
    {
        SDL_FreeSurface(ptr);
    }
}
