module api.dm.com.graphics.com_renderer;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.destroyable : Destroyable;

import api.math.geom2.vec2 : Vec2d, Vec2i;
import api.math.geom2.rect2 : Rect2d, Rect2i;

/**
 * Authors: initkfs
 */
interface ComRenderer : Destroyable
{
nothrow:

    ComResult setDrawColor(ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult getDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a);
    ComResult clear();
    ComResult present();
    ComResult copy(ComTexture texture);
    ComResult setClipRect(Rect2d clip);
    ComResult getClipRect(out Rect2d clip);
    ComResult removeClipRect();
    ComResult setBlendMode(ComBlendMode mode);
    ComResult getBlendMode(out ComBlendMode mode);
    ComResult setBlendModeBlend();
    ComResult setBlendModeNone();
    ComResult drawPoint(int x, int y);
    ComResult drawPoints(Vec2d[] points);
    ComResult drawPoints(Vec2i[] points);
    ComResult drawRect(int x, int y, int width, int height);
    ComResult drawRects(Rect2d[] rects);
    ComResult drawRects(Rect2i[] rects);
    ComResult drawFillRect(int x, int y, int width, int height);
    ComResult drawFillRects(Rect2d[] rects);
    ComResult drawFillRects(Rect2i[] rects);
    ComResult drawLine(int startX, int startY, int endX, int endY);
    ComResult drawLines(Vec2d[] linePoints);
    ComResult drawLines(Vec2i[] linePoints);
    ComResult getOutputSize(out int width, out int height);
    ComResult setScale(double scaleX, double scaleY);
    ComResult getScale(out double scaleX, out double scaleY);
    ComResult setViewport(Rect2d viewport);
    ComResult getViewport(out Rect2d viewport);
    ComResult setLogicalSize(int w, int h);
    ComResult getLogicalSize(out int w, out int h);
    ComResult readPixels(Rect2d rect, uint format, int pitch, void* pixelBuffer);
}
