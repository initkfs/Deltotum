module deltotum.sys.sdl.sdl_renderer;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.sys.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_texture : SdlTexture;

import deltotum.kit.sprites.flip : Flip;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlRenderer : SdlObjectWrapper!SDL_Renderer
{
    SdlWindow window;

    this(SDL_Renderer* ptr)
    {
        super(ptr);
    }

    this(SdlWindow window, uint flags = 0, int driverIndex = -1)
    {
        super();

        import std.exception : enforce;

        enforce(window !is null, "Window must not be null");

        ptr = SDL_CreateRenderer(window.getObject,
            driverIndex, flags);
        if (ptr is null)
        {
            string msg = "Cannot initialize renderer.";
            if (const err = getError)
            {
                msg ~= err;
            }
            throw new Exception(msg);
        }

        this.window = window;
    }

    ComResult setRenderDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) @nogc nothrow
    {
        ubyte oldR, oldG, oldB, oldA;
        //TODO log?
        const int zeroOrErrorColor = SDL_GetRenderDrawColor(ptr,
            &oldR, &oldG, &oldB, &oldA);
        if (zeroOrErrorColor)
        {
            return ComResult(zeroOrErrorColor, "Error getting render old color for drawing");
        }

        if (r == oldR && g == oldG && b == oldB && a == oldA)
        {
            return ComResult();
        }

        const int zeroOrErrorCode = SDL_SetRenderDrawColor(ptr, r, g, b, a);
        if (zeroOrErrorCode)
        {
            return ComResult(zeroOrErrorCode, "RGBA drawing error");
        }

        return ComResult();
    }

    ComResult clear() @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderClear(ptr);
        return ComResult(zeroOrErrorCode);
    }

    void present() @nogc nothrow
    {
        SDL_RenderPresent(ptr);
    }

    ComResult copy(SdlTexture texture) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderCopy(ptr, texture.getObject, null, null);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawRect(int x, int y, int width, int height)
    {
        SDL_Rect rect = {x, y, width, height};
        return drawRect(&rect);
    }

    ComResult drawRect(const SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawRect(ptr, rect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawPoint(int x, int y) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawPoint(ptr, x, y);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawLine(int startX, int startY, int endX, int endY) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawLine(ptr, startX, startY, endX, endY);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawLines(Vector2d[] linePoints) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_Point[] points = linePoints.map!(p => SDL_Point(cast(int) p.x, cast(int) p.y)).array;
        const int zeroOrErrorCode = SDL_RenderDrawLines(ptr,
            points.ptr,
            cast(int) points.length);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setViewport(SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderSetViewport(ptr, rect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult fillRect(int x, int y, int width, int height) @nogc nothrow
    {
        SDL_Rect rect = {x, y, width, height};
        return fillRect(&rect);
    }

    ComResult fillRect(const SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderFillRect(ptr, rect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult copyEx(SdlTexture texture, const SDL_Rect* srcRect, const SDL_Rect* destRect, double angle, const SDL_Point* center, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        const int zeroOrErrorCode = SDL_RenderCopyEx(ptr, texture.getObject, srcRect, destRect, angle, center, flip);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getOutputSize(int* width, int* height) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_GetRendererOutputSize(ptr, width, height);
        return ComResult(zeroOrErrorCode);
    }

    override protected bool destroyPtr()
    {
        if (ptr)
        {
            SDL_DestroyRenderer(ptr);
            return true;
        }
        return false;
    }
}
