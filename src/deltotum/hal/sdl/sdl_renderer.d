module deltotum.hal.sdl.sdl_renderer;

import deltotum.hal.sdl.base.sdl_object_wrapper : SdlObjectWrapper;
import deltotum.hal.sdl.sdl_window : SdlWindow;
import deltotum.hal.sdl.sdl_texture : SdlTexture;

import deltotum.display.flip: Flip;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d: Rect2d;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlRenderer : SdlObjectWrapper!SDL_Renderer
{
    @property SdlWindow window;

    this(SDL_Renderer* ptr)
    {
        super(ptr);
    }

    this(SdlWindow window, uint flags = 0)
    {
        super();
        this.window = window;
        enum firstDriverIndex = -1;
        ptr = SDL_CreateRenderer(window.getStruct,
            firstDriverIndex, flags);
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
        ubyte oldR, oldG, oldB, oldA;
        //TODO log?
        const int zeroOrErrorColor = SDL_GetRenderDrawColor(ptr,
            &oldR, &oldG, &oldB, &oldA);
        if (r == oldR && g == oldG && b == oldB && a == oldA)
        {
            return 0;
        }

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

    int drawRect(int x, int y, int width, int height)
    {
        SDL_Rect rect = {x, y, width, height};
        return drawRect(&rect);
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

    int drawLines(Vector2d[] linePoints) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_Point[] points = linePoints.map!(p => SDL_Point(cast(int) p.x, cast(int) p.y)).array;
        const int zeroOrErrorCode = SDL_RenderDrawLines(ptr,
            points.ptr,
            cast(int) points.length);
        return zeroOrErrorCode;
    }

    int drawTexture(SdlTexture texture, Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none)
    {
        {
            SDL_Rect srcRect;
            srcRect.x = cast(int) textureBounds.x;
            srcRect.y = cast(int) textureBounds.y;
            srcRect.w = cast(int) textureBounds.width;
            srcRect.h = cast(int) textureBounds.height;

            SDL_Rect bounds = window.getScaleBounds;

            SDL_Rect destRect;
            destRect.x = cast(int)(destBounds.x + bounds.x);
            destRect.y = cast(int)(destBounds.y + bounds.y);
            destRect.w = cast(int) destBounds.width;
            destRect.h = cast(int) destBounds.height;

            //FIXME some texture sizes can crash when changing the angle
            //double newW = height * abs(Math.sinDeg(angle)) + width * abs(Math.cosDeg(angle));
            //double newH = height * abs(Math.cosDeg(angle)) + width * abs(Math.sinDeg(angle));

            //TODO move to helper
            SDL_RendererFlip sdlFlip;
            final switch (flip)
            {
            case Flip.none:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_NONE;
                break;
            case Flip.horizontal:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_HORIZONTAL;
                break;
            case Flip.vertical:
                sdlFlip = SDL_RendererFlip.SDL_FLIP_VERTICAL;
                break;
            }

            //https://discourse.libsdl.org/t/1st-frame-sdl-renderer-software-sdl-flip-horizontal-ubuntu-wrong-display-is-it-a-bug-of-sdl-rendercopyex/25924
            return copyEx(texture, &srcRect, &destRect, angle, null, sdlFlip);
        }
    }

    int setViewport(SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderSetViewport(ptr, rect);
        return zeroOrErrorCode;
    }

    int fillRect(int x, int y, int width, int height) @nogc nothrow
    {
        SDL_Rect rect = {x, y, width, height};
        return fillRect(&rect);
    }

    int fillRect(SDL_Rect* rect) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_RenderFillRect(ptr, rect);
        return zeroOrErrorCode;
    }

    int copyEx(SdlTexture texture, SDL_Rect* srcRect, SDL_Rect* destRect, double angle, SDL_Point* center, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        const int zeroOrErrorCode = SDL_RenderCopyEx(ptr, texture.getStruct, srcRect, destRect, angle, center, flip);
        return zeroOrErrorCode;
    }

    int getOutputSize(int* width, int* height) @nogc nothrow
    {
        const int zeroOrErrorCode = SDL_GetRendererOutputSize(ptr, width, height);
        return zeroOrErrorCode;
    }

    void setRendererTarget(SDL_Texture* texture)
    {
        SDL_SetRenderTarget(ptr, texture);
    }

    void resetRendererTarget()
    {
        SDL_SetRenderTarget(ptr, null);
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
