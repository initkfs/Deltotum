module api.dm.back.sdl2.sdl_renderer;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_renderer : ComRenderer;
import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.back.sdl2.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl2.sdl_window : SdlWindow;
import api.dm.back.sdl2.sdl_texture : SdlTexture;

import api.math.flip : Flip;
import api.math.vec2 : Vec2d, Vec2i;
import api.math.rect2d : Rect2d, Rect2i;

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
        //SDL_RenderSetLogicalSize(ptr, w, h);
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
            return ComResult.success;
        }

        const int zeroOrErrorCode = SDL_SetRenderDrawColor(ptr, r, g, b, a);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }

        return ComResult.success;
    }

    ComResult getDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        const int zeroOrErrorColor = SDL_GetRenderDrawColor(ptr,
            &r, &g, &b, &a);
        if (zeroOrErrorColor)
        {
            return getErrorRes(zeroOrErrorColor, "Error getting render old color for drawing");
        }

        return ComResult.success;
    }

    ComResult clear() nothrow
    {
        const int zeroOrErrorCode = SDL_RenderClear(ptr);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult present() nothrow
    {
        SDL_RenderPresent(ptr);
        return ComResult.success;
    }

    ComResult copy(ComTexture texture) nothrow
    {
        import api.core.utils.types : castSafe;

        if (auto sdlTexture = texture.castSafe!SdlTexture)
        {
            ComNativePtr nPtr;
            if (const err = texture.nativePtr(nPtr))
            {
                return err;
            }
            //TODO unsafe
            SDL_Texture* sdlPtr = nPtr.castSafe!(SDL_Texture*);
            const int zeroOrErrorCode = SDL_RenderCopy(ptr, sdlPtr, null, null);
            if (zeroOrErrorCode)
            {
                return getErrorRes(zeroOrErrorCode);
            }
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
        const zeroOrErrorCode = SDL_RenderSetClipRect(ptr, &rect);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
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
        const zeroOrErrorCode = SDL_RenderSetClipRect(ptr, null);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult readPixels(Rect2d rect, uint format, int pitch, void* pixelBuffer) nothrow
    {
        SDL_Rect bounds;
        bounds.x = cast(int) rect.x;
        bounds.y = cast(int) rect.y;
        bounds.w = cast(int) rect.width;
        bounds.h = cast(int) rect.height;
        const zeroOrErrorCode = SDL_RenderReadPixels(ptr, &bounds, format, pixelBuffer, pitch);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }

        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        SDL_BlendMode newMode = typeConverter.toNativeBlendMode(mode);
        const int zeroOrErrorCode = SDL_SetRenderDrawBlendMode(ptr, newMode);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
        SDL_BlendMode oldMode;
        const int zeroOrErrorCode = SDL_GetRenderDrawBlendMode(ptr, &oldMode);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        mode = typeConverter.fromNativeBlendMode(oldMode);
        return ComResult.success;
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
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawRects(SDL_Rect[] rects) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawRects(ptr, rects.ptr, cast(int) rects.length);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    protected SDL_Rect[] toSdlRects(Rect2d[] rects) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_Rect[] sdlRects = rects.map!(rect => SDL_Rect(cast(int) rect.x, cast(int) rect.y, cast(
                int) rect.width, cast(int) rect.height)).array;
        return sdlRects;
    }

    ComResult drawRects(Rect2d[] rects) nothrow => drawRects(toSdlRects(rects));
    ComResult drawRects(Rect2i[] rects) nothrow => drawRects(cast(SDL_Rect[]) rects);

    ComResult drawPoint(int x, int y) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawPoint(ptr, x, y);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    private SDL_Point[] toPoints(Vec2d[] vecs) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_Point[] points = vecs.map!(p => SDL_Point(cast(int) p.x, cast(int) p.y)).array;
        return points;
    }

    ComResult drawPoints(SDL_Point[] ps) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawPoints(ptr, ps.ptr, cast(int) ps.length);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawPoints(Vec2d[] ps) nothrow => drawPoints(toPoints(ps));
    ComResult drawPoints(Vec2i[] ps) nothrow => drawPoints(cast(SDL_Point[]) ps);

    ComResult drawLine(int startX, int startY, int endX, int endY) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawLine(ptr, startX, startY, endX, endY);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawLines(SDL_Point[] linePoints) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderDrawLines(ptr,
            linePoints.ptr,
            cast(int) linePoints.length);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawLines(Vec2d[] linePoints) nothrow
    {
        return drawLines(toPoints(linePoints));
    }

    ComResult drawLines(Vec2i[] linePoints) nothrow
    {
        return drawLines(cast(SDL_Point[]) linePoints);
    }

    ComResult setViewport(SDL_Rect* rect) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderSetViewport(ptr, rect);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawFillRect(int x, int y, int width, int height) nothrow
    {
        SDL_Rect rect = {x, y, width, height};
        return drawFillRect(&rect);
    }

    ComResult drawFillRect(const SDL_Rect* rect) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderFillRect(ptr, rect);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawFillRects(SDL_Rect[] rects) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderFillRects(ptr, rects.ptr, cast(int) rects.length);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult drawFillRects(Rect2d[] rects) nothrow => drawFillRects(toSdlRects(rects));
    ComResult drawFillRects(Rect2i[] rects) nothrow => drawFillRects(cast(SDL_Rect[]) rects);

    ComResult copyEx(SdlTexture texture, const SDL_Rect* srcRect, const SDL_Rect* destRect, double angle, const SDL_Point* center, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE) nothrow
    {
        const int zeroOrErrorCode = SDL_RenderCopyEx(ptr, texture.getObject, srcRect, destRect, angle, center, flip);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getOutputSize(out int width, out int height) nothrow
    {
        int w, h;
        const int zeroOrErrorCode = SDL_GetRendererOutputSize(ptr, &w, &h);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        width = w;
        height = h;

        return ComResult.success;
    }

    ComResult setScale(double scaleX, double scaleY)
    {
        import std.conv : to;

        float sX = scaleX.to!float, sY = scaleY.to!float;
        const int zeroOrErrorCode = SDL_RenderSetScale(ptr, sX, sY);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getScale(out double scaleX, out double scaleY)
    {
        float sX = 0, sY = 0;
        SDL_RenderGetScale(ptr, &sX, &sY);
        scaleX = sX;
        scaleY = sY;
        return ComResult.success;
    }

    ComResult setViewport(Rect2d viewport)
    {
        SDL_Rect rect = {
            x: cast(int) viewport.x,
            y: cast(int) viewport.y,
            w: cast(int) viewport.width,
            h: cast(int) viewport.height
        };
        const zeroOrErrorCode = SDL_RenderSetViewport(ptr, &rect);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getViewport(out Rect2d viewport)
    {
        SDL_Rect rect;
        SDL_RenderGetViewport(ptr, &rect);
        viewport = Rect2d(rect.x, rect.y, rect.w, rect.h);

        return ComResult.success;
    }

    ComResult setLogicalSize(int w, int h)
    {
        const zeroOrErrorCode = SDL_RenderSetLogicalSize(ptr, w, h);
        if (zeroOrErrorCode)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    ComResult getLogicalSize(out int w, out int h)
    {
        SDL_RenderGetLogicalSize(ptr, &w, &h);
        return ComResult.success;
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
