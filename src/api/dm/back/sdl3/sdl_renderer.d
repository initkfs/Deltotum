module api.dm.back.sdl3.sdl_renderer;

import api.dm.com.platforms.results.com_result;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_renderer : ComRenderer, ComRendererLogicalScaling;
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
    this(SDL_Renderer* ptr)
    {
        super(ptr);
    }

    ComResult getName(out string name) nothrow
    {
        assert(ptr);
        const(char*) rName = SDL_GetRendererName(ptr);
        if (!rName)
        {
            return getErrorRes("Error getting SDL renderer name");
        }
        import std.string : fromStringz;

        name = rName.fromStringz.idup;
        return ComResult.success;
    }

    ComResult clearAndFill() nothrow
    {
        if (!tryClearAndFill)
        {
            return getErrorRes("Error clear SDL render");
        }
        return ComResult.success;
    }

    bool tryClearAndFill() nothrow => SDL_RenderClear(ptr);

    ComResult present() nothrow
    {
        if (!tryPresent)
        {
            return getErrorRes("Error present SDL renderer");
        }
        return ComResult.success;
    }

    bool tryPresent() nothrow => SDL_RenderPresent(ptr);

    ComResult setDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        if (!trySetDrawColor(r, g, b, a))
        {
            return getErrorRes("Error setting SDL render color");
        }

        return ComResult.success;
    }

    bool tryFlush() nothrow => SDL_FlushRenderer(ptr);

    ComResult flush() nothrow
    {
        if (!tryFlush)
        {
            return getErrorRes("Error flushing SDL renderer");
        }
        return ComResult.success;
    }

    bool trySetDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow
    {
        return SDL_SetRenderDrawColor(ptr, r, g, b, a);
    }

    ComResult getDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        if (!tryGetDrawColor(r, g, b, a))
        {
            return getErrorRes("Error getting render old color for drawing");
        }

        return ComResult.success;
    }

    bool tryGetDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow
    {
        return SDL_GetRenderDrawColor(ptr, &r, &g, &b, &a);
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
            return getErrorRes("Error setting SDL renderer clip");
        }
        return ComResult.success;
    }

    ComResult getClipRect(out Rect2d clip) nothrow
    {
        SDL_Rect rect;
        if (!SDL_GetRenderClipRect(ptr, &rect))
        {
            return getErrorRes("Error getting SDL renderer clip");
        }
        clip = Rect2d(rect.x, rect.y, rect.w, rect.h);
        return ComResult.success;
    }

    ComResult getIsClip(out bool isClip) nothrow
    {
        isClip = SDL_RenderClipEnabled(ptr);
        return ComResult.success;
    }

    ComResult removeClipRect() nothrow
    {
        if (!SDL_SetRenderClipRect(ptr, null))
        {
            return getErrorRes("Error removing SDL renderer clip");
        }
        return ComResult.success;
    }

    ComResult setBlendMode(ComBlendMode mode) nothrow
    {
        SDL_BlendMode newMode = toNativeBlendMode(mode);
        if (!SDL_SetRenderDrawBlendMode(ptr, newMode))
        {
            return getErrorRes("Error setting SDL renderer blend mode");
        }
        return ComResult.success;
    }

    ComResult getBlendMode(out ComBlendMode mode) nothrow
    {
        SDL_BlendMode oldMode;
        if (!SDL_GetRenderDrawBlendMode(ptr, &oldMode))
        {
            return getErrorRes("Error getting SDL renderer blend mode");
        }
        mode = fromNativeBlendMode(oldMode);
        return ComResult.success;
    }

    ComResult setBlendModeBlend() nothrow => setBlendMode(ComBlendMode.blend);
    ComResult setBlendModeNone() nothrow => setBlendMode(ComBlendMode.none);

    private SDL_FPoint[] toSdlPoints(Vec2d[] vecs) nothrow
    {
        import std.algorithm.iteration : map;
        import std.array : array;

        SDL_FPoint[] points = vecs.map!(p => SDL_FPoint(cast(float) p.x, cast(float) p.y)).array;
        return points;
    }

    ComResult drawPoint(float x, float y) nothrow
    {
        if (!SDL_RenderPoint(ptr, x, y))
        {
            return getErrorRes("Error drawing point with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawPoints(SDL_FPoint[] ps) nothrow
    {
        if (!SDL_RenderPoints(ptr, ps.ptr, cast(int) ps.length))
        {
            return getErrorRes("Error drawing points with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawPoints(Vec2d[] ps) nothrow => drawPoints(toSdlPoints(ps));
    ComResult drawPoints(Vec2f[] ps) nothrow => drawPoints(cast(SDL_FPoint[]) ps);

    ComResult drawLine(float startX, float startY, float endX, float endY) nothrow
    {
        if (!SDL_RenderLine(ptr, startX, startY, endX, endY))
        {
            return getErrorRes("Error drawing line with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawLines(SDL_FPoint[] linePoints) nothrow
    {
        if (!SDL_RenderLines(ptr, linePoints.ptr, cast(int) linePoints.length))
        {
            return getErrorRes("Error drawing lines with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawLines(Vec2d[] linePoints) nothrow => drawLines(toSdlPoints(linePoints));
    ComResult drawLines(Vec2f[] linePoints) nothrow => drawLines(cast(SDL_FPoint[]) linePoints);

    ComResult drawRect(float x, float y, float width, float height) nothrow
    {
        SDL_FRect r = {x, y, width, height};
        return drawRect(&r);
    }

    ComResult drawRect(SDL_FRect* r) nothrow
    {
        if (!SDL_RenderRect(ptr, r))
        {
            return getErrorRes("Error drawing rectangle with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawRects(SDL_FRect[] rects) nothrow
    {
        if (!SDL_RenderRects(ptr, rects.ptr, cast(int) rects.length))
        {
            return getErrorRes("Error drawing rectangles with SDL renderer");
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

    ComResult drawFillRect(int x, int y, int width, int height) nothrow
    {
        SDL_FRect rect = {x, y, width, height};
        return drawFillRect(&rect);
    }

    ComResult drawFillRect(SDL_FRect* rect) nothrow
    {
        if (!SDL_RenderFillRect(ptr, rect))
        {
            return getErrorRes("Error filling rectangle with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawFillRects(SDL_FRect[] rects) nothrow
    {
        if (!SDL_RenderFillRects(ptr, rects.ptr, cast(int) rects.length))
        {
            return getErrorRes("Error filling rectangles with SDL renderer");
        }
        return ComResult.success;
    }

    ComResult drawFillRects(Rect2d[] rects) nothrow => drawFillRects(toSdlRects(rects));
    ComResult drawFillRects(Rect2f[] rects) nothrow => drawFillRects(cast(SDL_FRect[]) rects);

    ComResult getOutputSize(out int width, out int height) nothrow
    {
        int w, h;
        if (!SDL_GetCurrentRenderOutputSize(ptr, &w, &h))
        {
            return getErrorRes("Error getting SDL renderer output size");
        }

        width = w;
        height = h;

        return ComResult.success;
    }

    ComResult getSafeBounds(out Rect2d bounds) nothrow
    {
        SDL_Rect* safeBounds;
        if (!SDL_GetRenderSafeArea(ptr, safeBounds))
        {
            return getErrorRes("Error getting SDL renderer safe area");
        }
        bounds = Rect2d(safeBounds.x, safeBounds.y, safeBounds.w, safeBounds.h);
        return ComResult.success;
    }

    ComResult getScale(out float scaleX, out float scaleY) nothrow
    {
        float sX = 0, sY = 0;
        if (!SDL_GetRenderScale(ptr, &sX, &sY))
        {
            return getErrorRes("Error getting SDL renderer scale");
        }
        scaleX = sX;
        scaleY = sY;
        return ComResult.success;
    }

    ComResult setScale(float scaleX, float scaleY) nothrow
    {
        if (!SDL_SetRenderScale(ptr, scaleX, scaleY))
        {
            return getErrorRes("Error setting SDL renderer scale");
        }
        return ComResult.success;
    }

    ComResult getViewport(out Rect2d viewport) nothrow
    {
        SDL_Rect rect;
        if (!SDL_GetRenderViewport(ptr, &rect))
        {
            return getErrorRes("Error getting SDL renderer viewport");
        }

        viewport = Rect2d(rect.x, rect.y, rect.w, rect.h);

        return ComResult.success;
    }

    protected ComResult setViewport(SDL_Rect* rect) nothrow
    {
        if (!SDL_SetRenderViewport(ptr, rect))
        {
            return getErrorRes("Error setting SDL renderer viewport");
        }
        return ComResult.success;
    }

    ComResult setViewport(Rect2d viewport) nothrow
    {
        SDL_Rect rect = {
            x: cast(int) viewport.x,
            y: cast(int) viewport.y,
            w: cast(int) viewport.width,
            h: cast(int) viewport.height
        };
        return setViewport(&rect);
    }

    ComResult getLogicalSize(out int w, out int h, out ComRendererLogicalScaling mode) nothrow
    {
        SDL_RendererLogicalPresentation rmode;
        if (!SDL_GetRenderLogicalPresentation(ptr, &w, &h, &rmode))
        {
            return getErrorRes("Error getting SDL renderer logical size");
        }
        mode = fromSdlPresentation(rmode);
        return ComResult.success;
    }

    ComResult setLogicalSize(int w, int h, ComRendererLogicalScaling mode) nothrow
    {
        SDL_RendererLogicalPresentation sdlMode = toSdlPresentation(mode);
        if (!SDL_SetRenderLogicalPresentation(ptr, w, h, sdlMode))
        {
            return getErrorRes("Error setting SDL renderer logical size");
        }
        return ComResult.success;
    }

    protected SDL_RendererLogicalPresentation toSdlPresentation(ComRendererLogicalScaling mode) pure @safe nothrow
    {
        final switch (mode) with (ComRendererLogicalScaling)
        {
            case none:
                return SDL_LOGICAL_PRESENTATION_DISABLED;
            case stretch:
                return SDL_LOGICAL_PRESENTATION_STRETCH;
            case letterbox:
                return SDL_LOGICAL_PRESENTATION_LETTERBOX;
            case overscan:
                return SDL_LOGICAL_PRESENTATION_OVERSCAN;
            case integerscale:
                return SDL_LOGICAL_PRESENTATION_INTEGER_SCALE;
        }
    }

    protected ComRendererLogicalScaling fromSdlPresentation(SDL_RendererLogicalPresentation mode) pure @safe nothrow
    {
        final switch (mode) with (SDL_RendererLogicalPresentation)
        {
            case SDL_LOGICAL_PRESENTATION_DISABLED:
                return ComRendererLogicalScaling.none;
            case SDL_LOGICAL_PRESENTATION_STRETCH:
                return ComRendererLogicalScaling.stretch;
            case SDL_LOGICAL_PRESENTATION_LETTERBOX:
                return ComRendererLogicalScaling.letterbox;
            case SDL_LOGICAL_PRESENTATION_OVERSCAN:
                return ComRendererLogicalScaling.overscan;
            case SDL_LOGICAL_PRESENTATION_INTEGER_SCALE:
                return ComRendererLogicalScaling.integerscale;
        }
    }

    bool renderTexture(SDL_Texture* texture, SDL_FRect* src, SDL_FRect* dst)
    {
        return SDL_RenderTexture(ptr, texture, src, dst);
    }

    ComResult renderTextureEx(SdlTexture texture, SDL_FRect* srcRect = null, SDL_FRect* destRect = null, double angle = 0, SDL_FPoint* center = null, SDL_FlipMode flip = SDL_FLIP_NONE) nothrow
    {
        const result = SDL_RenderTextureRotated(ptr, texture.getObject, srcRect, destRect, angle, center, flip);
        if (!result)
        {
            return getErrorRes;
        }
        return ComResult.success;
    }

    // ComResult renderTexture(ComTexture texture, SDL_Rect* src, SDL_Rect* dst)
    // {
    //     if (auto sdlTexture = cast(SdlTexture) texture)
    //     {
    //         ComNativePtr nPtr;
    //         if (const err = texture.nativePtr(nPtr))
    //         {
    //             return err;
    //         }

    //         SDL_Texture* sdlPtr = nPtr.castSafe!(SDL_Texture*);
    //         if (!renderTexture(sdlPtr, src, dst))
    //         {
    //             return getErrorRes("Error render SDL texture with renderer");
    //         }
    //         return ComResult.success;
    //     }
    //     return ComResult.error("Source texture is not a sdl texture");
    // }

    // ComResult drawTexture(ComTexture texture) nothrow => renderTexture(texture, null, null);

    // ComResult drawTexture(ComTexture texture, Rect2d srcRect, Rect2d dstRect) nothrow
    // {
    //     SDL_Rect src = toSdlRects(srcRect);
    //     SDL_Rect dst = toSdlRects(dstRect);
    //     return renderTexture(texture, &src, &dst);
    // }

    // ComResult renderTextureEx(ComTexture texture, SDL_FRect* srcRect, SDL_FRect* dstRect,
    //     double angle, SDL_FPoint* center, SDL_FlipMode flip)
    // {
    //     if (auto sdlTexture = cast(SdlTexture) texture)
    //     {
    //         ComNativePtr nPtr;
    //         if (const err = texture.nativePtr(nPtr))
    //         {
    //             return err;
    //         }

    //         SDL_Texture* sdlPtr = nPtr.castSafe!(SDL_Texture*);
    //         if (!SDL_RenderTextureRotated(ptr, sdlPtr, srcRect, dstRect, angle, center, flip))
    //         {
    //             return getErrorRes("Error rendering SDL texture with rotation");
    //         }
    //         return ComResult.success;
    //     }
    //     return ComResult.error("Source texture is not a sdl texture");
    // }

    // ComResult drawTextureEx(ComTexture texture, Rect2d srcRect, Rect2d dstRect, double angle, Vec2d center, Flip flip) nothrow
    // {
    //     SDL_Rect src = toSdlRects(srcRect);
    //     SDL_rect dst = toSdlRects(dstRect);

    //     SDL_FRect sdlCenter = {cast(int) center.x, cast(int) center.y};

    //     SDL_FlipMode sdlFlip;
    //     final switch (flip)
    //     {
    //         case Flip.none:
    //             sdlFlip = SDL_FlipMode.SDL_FLIP_NONE;
    //             break;
    //         case Flip.horizontal:
    //             sdlFlip = SDL_FlipMode.SDL_FLIP_HORIZONTAL;
    //             break;
    //         case Flip.vertical:
    //             sdlFlip = SDL_FlipMode.SDL_FLIP_VERTICAL;
    //             break;
    //             sdlFlip = SDL_FlipMode.SDL_FLIP_VERTICAL | SDL_FlipMode.SDL_FLIP_HORIZONTAL;
    //         case Flip.both:
    //             break;
    //     }

    //     return renderTextureEx(texture, &src, &dst, angle, &sdlCenter, sdlFlip);
    // }

    //it should be called after rendering and before SDL_RenderPresent().
    ComResult readPixels(Rect2d rect, ComSurface buffer) nothrow
    {
        //TODO SDL_GetRenderLogicalPresentationRect
        //https://wiki.libsdl.org/SDL3/SDL_RenderReadPixels
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

    ComResult toRenderCoordinates(SDL_Event* event)
    {
        assert(ptr);

        if (!SDL_ConvertEventToRenderCoordinates(ptr, event))
        {
            return getErrorRes("Error converting SDL event to render coordinates");
        }
        return ComResult.success;
    }

    ComResult fromWindowToRenderCoordinates(float windowX, float windowY, out float renderX, out float renderY)
    {
        float rX = 0, rY = 0;
        if (!SDL_RenderCoordinatesFromWindow(ptr, windowX, windowY, &rX, &rY))
        {
            return getErrorRes("Error converting window coordinates to SDL renderer coordinates");
        }
        renderX = rX;
        renderY = rY;
        return ComResult.success;
    }

    ComResult renderCoordinatesToWindow(float renderX, float renderY, out float winX, out float winY)
    {
        float wX = 0, wY = 0;
        if (!SDL_RenderCoordinatesToWindow(ptr, renderX, renderY, &wX, &wY))
        {
            return getErrorRes("Error converting SDL renderer coordinates to window coordinates");
        }
        winX = wX;
        winY = wY;
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
