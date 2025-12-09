module api.dm.com.graphics.com_renderer;

import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_texture : ComTexture, ComTextureWrapMode;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.com_error_manageable: ComErrorManageable;

import api.math.pos2.flip: Flip;
import api.math.geom2.vec2 : Vec2d, Vec2f;
import api.math.geom2.rect2 : Rect2d, Rect2f;

enum ComRendererLogicalScaling {
    none,
    stretch,
    letterbox,
    overscan,
    integerscale
}

/**
 * Authors: initkfs
 */
interface ComRenderer : ComDestroyable, ComErrorManageable
{
nothrow:

    ComResult getName(out string name);

    ComResult clearAndFill();
    bool tryClearAndFill();

    ComResult present();
    bool tryPresent();

    ComResult flush();
    bool tryFlush();

    ComResult setDrawColor(ubyte r, ubyte g, ubyte b, ubyte a);
    bool trySetDrawColor(ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult getDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a);
    bool tryGetDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a);

    ComResult setClipRect(Rect2d clip);
    ComResult getClipRect(out Rect2d clip);
    ComResult getIsClip(out bool isClip);
    ComResult removeClipRect();

    ComResult setBlendMode(ComBlendMode mode);
    ComResult getBlendMode(out ComBlendMode mode);

    ComResult setBlendModeBlend();
    ComResult setBlendModeNone();

    bool drawPoint(float x, float y);
    bool drawPoints(Vec2d[] points);
    bool drawPoints(Vec2f[] points);

    bool drawLine(float startX, float startY, float endX, float endY);
    bool drawLines(Vec2d[] linePoints);
    //ComResult drawLines(Vec2d[] linePoints, size_t count);
    bool drawLines(Vec2f[] linePoints);

    bool drawRect(float x, float y, float width, float height);
    bool drawRects(Rect2d[] rects);
    bool drawRects(Rect2f[] rects);

    bool drawFillRect(float x, float y, float width, float height);
    bool drawFillRects(Rect2d[] rects);
    bool drawFillRects(Rect2f[] rects);

    ComResult getOutputSize(out int width, out int height);
    ComResult getSafeBounds(out Rect2d bounds);

    ComResult setScale(float scaleX, float scaleY);
    ComResult getScale(out float scaleX, out float scaleY);

    ComResult setViewport(Rect2d viewport);
    ComResult getViewport(out Rect2d viewport);

    ComResult getTextureWrapMode(out ComTextureWrapMode xMode, out ComTextureWrapMode yMode);
    ComResult setTextureWrapMode(ComTextureWrapMode xMode, ComTextureWrapMode yMode);

    ComResult getLogicalSize(out int w, out int h, out ComRendererLogicalScaling mode);
    ComResult setLogicalSize(int w, int h, ComRendererLogicalScaling mode);

    ComResult readPixels(Rect2d rect, ComSurface buffer);

    // ComResult drawTexture(ComTexture texture);
    // ComResult drawTexture(ComTexture texture, Rect2d srcRect, Rect2d dstRect);
    // ComResult drawTextureEx(ComTexture texture, Rect2d srcRect, Rect2d dstRect, float angle, Vec2d center, Flip flip);
}
