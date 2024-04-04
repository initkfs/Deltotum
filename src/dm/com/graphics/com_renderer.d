module dm.com.graphics.com_renderer;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_texture : ComTexture;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.destroyable : Destroyable;

import dm.math.vector2 : Vector2;
import dm.math.rect2d : Rect2d;

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
    ComResult readPixels(Rect2d rect, uint format, int pitch, void* pixelBuffer);
}
