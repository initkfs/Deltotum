module dm.back.sdl2.sdl_renderer;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.graphics.com_renderer : ComRenderer;
import dm.com.graphics.com_texture : ComTexture;
import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import dm.back.sdl2.sdl_window : SdlWindow;
import dm.back.sdl2.sdl_texture : SdlTexture;

import dm.math.flip : Flip;
import dm.math.vector2 : Vector2;
import dm.math.rect2d : Rect2d;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlRenderer : SdlObjectWrapper!SDL_Renderer, ComRenderer
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

    ComResult setDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        ubyte oldR, oldG, oldB, oldA;

        if (const err = getDrawColor(oldR, oldG, oldB, oldA))
        {
            return err;
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

    ComResult getDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        const int zeroOrErrorColor = SDL_GetRenderDrawColor(ptr,
            &r, &g, &b, &a);
        if (zeroOrErrorColor)
        {
            return ComResult(zeroOrErrorColor, "Error getting render old color for drawing");
        }

        return ComResult.success;
    }

    ComResult clear() nothrow
    {
        const int zeroOrErrorCode = SDL_RenderClear(ptr);
        return ComResult(zeroOrErrorCode);
    }

    ComResult present() nothrow
    {
        SDL_RenderPresent(ptr);
        return ComResult.success;
    }

    ComResult copy(ComTexture texture) nothrow
    {
        if (auto sdlTexture = cast(SdlTexture) texture)
        {
            void* nPtr;
            if (const err = texture.nativePtr(nPtr))
            {
                return err;
            }
            //TODO unsafe
            SDL_Texture* sdlPtr = cast(SDL_Texture*) nPtr;
            const int zeroOrErrorCode = SDL_RenderCopy(ptr, sdlPtr, null, null);
            return ComResult(zeroOrErrorCode);
        }
        return ComResult.error("Source texture is not a sdl texture");
    }

    ComResult setClipRect(Rect2d clip) nothrow
    {
        SDL_Rect rect;
        rect.x = cast(int) clip.x;
        rect.y = cast(int) clip.y;
        rect.w = cast(int) clip.width;
        rect.h = cast(int) clip.height;
        const zeroOrErrCode = SDL_RenderSetClipRect(ptr, &rect);
        return ComResult(zeroOrErrCode);
    }

    ComResult getClipRect(out Rect2d clip) nothrow
    {
        SDL_Rect rect;
        SDL_RenderGetClipRect(ptr, &rect);
        clip = Rect2d(rect.x, rect.y, rect.w, rect.h);
        return ComResult.success;
    }

    ComResult removeClipRect() nothrow
    {
        const zeroOrErrCode = SDL_RenderSetClipRect(ptr, null);
        return ComResult(zeroOrErrCode);
    }

    ComResult readPixels(Rect2d rect, uint format, int pitch, void* pixelBuffer) nothrow
    {
        SDL_Rect bounds;
        bounds.x = cast(int) rect.x;
        bounds.y = cast(int) rect.y;
        bounds.w = cast(int) rect.width;
        bounds.h = cast(int) rect.height;
        const zeroOrErrCode = SDL_RenderReadPixels(ptr, &bounds, format, pixelBuffer, pitch);
        if (zeroOrErrCode != 0)
        {
            return ComResult(zeroOrErrCode, getError);
        }

        return ComResult(zeroOrErrCode);
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        SDL_BlendMode newMode = typeConverter.toNativeBlendMode(mode);
        const int zeroOrErrorCode = SDL_SetRenderDrawBlendMode(ptr, newMode);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
        SDL_BlendMode oldMode;
        const int zeroOrErrorCode = SDL_GetRenderDrawBlendMode(ptr, &oldMode);
        if (zeroOrErrorCode == 0)
        {
            mode = typeConverter.fromNativeBlendMode(oldMode);
        }
        return ComResult(zeroOrErrorCode);
    }

    ComResult setBlendModeBlend() nothrow
    {
        return setBlendMode(ComBlendMode.blend);
    }

    ComResult setBlendModeNone() nothrow
    {
        return setBlendMode(ComBlendMode.none);
    }

    ComResult drawRect(int x, int y, int width, int height) nothrow
    {
        SDL_Rect r = {x, y, width, height};
        return drawRect(&r);
    }

    ComResult drawRect(const SDL_Rect* r) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawRect(ptr, r);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawPoint(int x, int y) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawPoint(ptr, x, y);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawLine(int startX, int startY, int endX, int endY) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawLine(ptr, startX, startY, endX, endY);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawLines(Vector2[] linePoints) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_Point[] points = linePoints.map!(p => SDL_Point(cast(int) p.x, cast(int) p.y)).array;
        const int zeroOrErrorCode = SDL_RenderDrawLines(ptr,
            points.ptr,
            cast(int) points.length);
        return ComResult(zeroOrErrorCode);
    }

    ComResult setViewport(SDL_Rect* rect) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderSetViewport(ptr, rect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult drawFillRect(int x, int y, int width, int height) nothrow
    {
        SDL_Rect rect = {x, y, width, height};
        return drawFillRect(&rect);
    }

    ComResult drawFillRect(const SDL_Rect* rect) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderFillRect(ptr, rect);
        return ComResult(zeroOrErrorCode);
    }

    ComResult copyEx(SdlTexture texture, const SDL_Rect* srcRect, const SDL_Rect* destRect, double angle, const SDL_Point* center, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderCopyEx(ptr, texture.getObject, srcRect, destRect, angle, center, flip);
        return ComResult(zeroOrErrorCode);
    }

    ComResult getOutputSize(int* width, int* height) nothrow
    {
        const int zeroOrErrorCode = SDL_GetRendererOutputSize(ptr, width, height);
        return ComResult(zeroOrErrorCode);
    }

    override protected bool disposePtr()
    {
        if (ptr)
        {
            SDL_DestroyRenderer(ptr);
            return true;
        }
        return false;
    }
}
