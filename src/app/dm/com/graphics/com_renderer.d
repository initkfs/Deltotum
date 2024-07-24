module app.dm.com.graphics.com_renderer;

import app.dm.com.platforms.results.com_result : ComResult;
import app.dm.com.graphics.com_texture : ComTexture;
import app.dm.com.graphics.com_blend_mode : ComBlendMode;
import app.dm.com.destroyable : Destroyable;

import app.dm.math.vector2 : Vector2;
import app.dm.math.rect2d : Rect2d;

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
    ComResult drawRect(int x, int y, int width, int height);
    ComResult drawFillRect(int x, int y, int width, int height);
    ComResult drawLine(int startX, int startY, int endX, int endY);
    ComResult drawLines(Vector2[] linePoints);
    ComResult getOutputSize(out int width, out int height);
    ComResult setScale(double scaleX, double scaleY);
    ComResult getScale(out double scaleX, out double scaleY);
    ComResult setViewport(Rect2d viewport);
    ComResult getViewport(out Rect2d viewport);
    ComResult setLogicalSize(int w, int h);
    ComResult getLogicalSize(out int w, out int h);
    ComResult readPixels(Rect2d rect, uint format, int pitch, void* pixelBuffer);
}
