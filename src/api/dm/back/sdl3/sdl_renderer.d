module api.dm.back.sdl3.sdl_renderer;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_renderer : ComRenderer;
import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.back.sdl3.base.sdl_object_wrapper : SdlObjectWrapper;
import api.dm.back.sdl3.sdl_window : SdlWindow;
import api.dm.back.sdl3.sdl_texture : SdlTexture;
import api.dm.com.graphics.com_surface : ComSurface;

import api.math.flip : Flip;
import api.math.geom2.vec2 : Vec2d, Vec2i, Vec2f;
import api.math.geom2.rect2 : Rect2d, Rect2i, Rect2f;

import api.dm.back.sdl3.externs.csdl3;

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

    this(SdlWindow window, string name = null)
    {
        super();

        import std.exception : enforce;

        enforce(window !is null, "Window must not be null");

        import std.string : toStringz;

        const char* namePtr = name ? name.toStringz : null;

        ptr = SDL_CreateRenderer(window.getObject, namePtr);
        if (!ptr)
        {
            string msg = "Cannot initialize renderer.";
            if (const err = getError)
            {
                msg ~= err;
            }
            throw new Exception(msg);
        }

        this.window = window;
        //SDL_SetRenderLogicalPresentation(ptr, w, h);
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

        if (!SDL_SetRenderDrawColor(ptr, r, g, b, a))
        {
            return getErrorRes;
        }

        return ComResult.success;
    }

    ComResult getDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        if (!SDL_GetRenderDrawColor(ptr, &r, &g, &b, &a))
        {
            return getErrorRes("Error getting render old color for drawing");
        }

        return ComResult.success;
    }

    ComResult clear() nothrow
    {
        if (!SDL_RenderClear(ptr))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult present() nothrow
    {
        if (!SDL_RenderPresent(ptr))
        {
            return getErrorRes;
        }
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
            if (!SDL_RenderTexture(ptr, sdlPtr, null, null))
            {
                return getErrorRes;
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
        if (!SDL_SetRenderClipRect(ptr, &rect))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getClipRect(out Rect2d clip) nothrow
    {
        SDL_Rect rect;
        if (!SDL_GetRenderClipRect(ptr, &rect))
        {
            return getErrorRes;
        }
        clip = Rect2d(rect.x, rect.y, rect.w, rect.h);
        return ComResult.success;
    }

    ComResult removeClipRect() nothrow
    {
        if (!SDL_SetRenderClipRect(ptr, null))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    //it should be called after rendering and before SDL_RenderPresent().
    ComResult readPixels(Rect2d rect, ComSurface buffer) nothrow
    {
        SDL_Rect bounds;
        bounds.x = cast(int) rect.x;
        bounds.y = cast(int) rect.y;
        bounds.w = cast(int) rect.width;
        bounds.h = cast(int) rect.height;

        try
        {
            SDL_Surface* surface = SDL_RenderReadPixels(ptr, &bounds);
            if (!surface)
            {
                return getErrorRes;
            }

            import api.dm.back.sdl3.sdl_surface : SdlSurface;

            auto sdlBuffer = cast(SdlSurface) buffer;
            sdlBuffer.updateObject(surface);
        }
        catch (Exception e)
        {
            return getErrorRes(e.msg);
        }

        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        SDL_BlendMode newMode = typeConverter.toNativeBlendMode(mode);
        if (!SDL_SetRenderDrawBlendMode(ptr, newMode))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
        SDL_BlendMode oldMode;
        if (!SDL_GetRenderDrawBlendMode(ptr, &oldMode))
        {
            return getErrorRes;
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

    ComResult drawRect(float x, float y, float width, float height) nothrow
    {
        SDL_FRect r = {x, y, width, height};
        return drawRect(&r);
    }

    ComResult drawRect(SDL_FRect* r) nothrow
    {
        if (!SDL_RenderRect(ptr, r))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawRects(SDL_FRect[] rects) nothrow
    {
        if (SDL_RenderRects(ptr, rects.ptr, cast(int) rects.length))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    protected SDL_FRect[] toSdlRects(Rect2d[] rects) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_FRect[] sdlRects = rects.map!(rect => SDL_FRect(cast(float) rect.x, cast(float) rect.y, cast(
                float) rect.width, cast(float) rect.height)).array;
        return sdlRects;
    }

    ComResult drawRects(Rect2d[] rects) nothrow => drawRects(toSdlRects(rects));
    ComResult drawRects(Rect2f[] rects) nothrow => drawRects(cast(SDL_FRect[]) rects);

    ComResult drawPoint(float x, float y) nothrow
    {
        if (!SDL_RenderPoint(ptr, x, y))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    private SDL_FPoint[] toPoints(Vec2d[] vecs) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_FPoint[] points = vecs.map!(p => SDL_FPoint(cast(float) p.x, cast(float) p.y)).array;
        return points;
    }

    ComResult drawPoints(SDL_FPoint[] ps) nothrow
    {
        if (!SDL_RenderPoints(ptr, ps.ptr, cast(int) ps.length))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawPoints(Vec2d[] ps) nothrow => drawPoints(toPoints(ps));
    ComResult drawPoints(Vec2f[] ps) nothrow => drawPoints(cast(SDL_FPoint[]) ps);

    ComResult drawLine(float startX, float startY, float endX, float endY) nothrow
    {
        if (!SDL_RenderLine(ptr, startX, startY, endX, endY))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawLines(SDL_FPoint[] linePoints) nothrow => drawLines(linePoints, linePoints.length);
    ComResult drawLines(SDL_FPoint[] linePoints, size_t count) nothrow
    {
        assert(count <= linePoints.length);
        if (!SDL_RenderLines(ptr, linePoints.ptr, cast(int) count))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawLines(Vec2d[] linePoints) nothrow => drawLines(
        linePoints, linePoints.length);

    ComResult drawLines(Vec2d[] linePoints, size_t count) nothrow
    {
        auto tp = toPoints(linePoints);
        assert(count <= tp.length);
        return drawLines(tp, count);
    }

    ComResult drawLines(Vec2f[] linePoints) nothrow
    {
        return drawLines(cast(SDL_FPoint[]) linePoints);
    }

    ComResult setViewport(SDL_Rect* rect) nothrow
    {
        if (!SDL_SetRenderViewport(ptr, rect))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawFillRect(int x, int y, int width, int height) nothrow
    {
        SDL_FRect rect = {x, y, width, height};
        return drawFillRect(&rect);
    }

    ComResult drawFillRect(SDL_FRect* rect) nothrow
    {
        if (!SDL_RenderFillRect(ptr, rect))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawFillRects(SDL_FRect[] rects) nothrow
    {
        if (!SDL_RenderFillRects(ptr, rects.ptr, cast(int) rects.length))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult drawFillRects(Rect2d[] rects) nothrow => drawFillRects(toSdlRects(rects));
    ComResult drawFillRects(Rect2f[] rects) nothrow => drawFillRects(cast(SDL_FRect[]) rects);

    ComResult copyEx(SdlTexture texture, SDL_FRect* srcRect, SDL_FRect* destRect, double angle, SDL_FPoint* center, SDL_FlipMode flip = SDL_FLIP_NONE) nothrow
    {
        const result = SDL_RenderTextureRotated(ptr, texture.getObject, srcRect, destRect, angle, center, flip);
        if (!result)
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getOutputSize(out int width, out int height) nothrow
    {
        int w, h;
        if (!SDL_GetCurrentRenderOutputSize(ptr, &w, &h))
        {
            return getErrorRes;
        }
        width = w;
        height = h;

        return ComResult.success;
    }

    ComResult setScale(double scaleX, double scaleY)
    {
        import std.conv : to;

        float sX = scaleX.to!float, sY = scaleY.to!float;
        if (!SDL_SetRenderScale(ptr, sX, sY))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getScale(out double scaleX, out double scaleY)
    {
        float sX = 0, sY = 0;
        if (!SDL_GetRenderScale(ptr, &sX, &sY))
        {
            return getErrorRes;
        }
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

        if (!SDL_SetRenderViewport(ptr, &rect))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getViewport(out Rect2d viewport)
    {
        SDL_Rect rect;
        if (!SDL_GetRenderViewport(ptr, &rect))
        {
            return getErrorRes;
        }
        viewport = Rect2d(rect.x, rect.y, rect.w, rect.h);

        return ComResult.success;
    }

    ComResult setLogicalSize(int w, int h)
    {
        uint mode = SDL_LOGICAL_PRESENTATION_DISABLED;
        if (!SDL_SetRenderLogicalPresentation(ptr, w, h, cast(SDL_RendererLogicalPresentation) mode))
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    ComResult getLogicalSize(out int w, out int h, out uint mode)
    {
        SDL_RendererLogicalPresentation rmode = cast(SDL_RendererLogicalPresentation) mode;
        if (!SDL_GetRenderLogicalPresentation(ptr, &w, &h, &rmode))
        {
            return getErrorRes;
        }
        mode = rmode;
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
