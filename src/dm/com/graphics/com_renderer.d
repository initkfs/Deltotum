module dm.com.graphics.com_renderer;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_texture: ComTexture;
import dm.com.graphics.com_blend_mode: ComBlendMode;
import dm.com.lifecycles.destroyable : Destroyable;

import dm.math.vector2: Vector2;
import dm.math.rect2d: Rect2d;

/**
 * Authors: initkfs
 */
interface ComRenderer : Destroyable
{
    ComResult setRenderDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) @nogc nothrow;
    ComResult getRenderDrawColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) @nogc nothrow;
    ComResult clear() @nogc nothrow;
    void present() @nogc nothrow;
    ComResult copy(ComTexture texture);
    ComResult setClipRect(Rect2d clip) @nogc nothrow;
    ComResult getClipRect(out Rect2d clip) @nogc nothrow;
    ComResult removeClipRect() @nogc nothrow;
    ComResult setBlendMode(ComBlendMode mode) @nogc nothrow;
    ComResult getBlendMode(out ComBlendMode mode) @nogc nothrow;
    ComResult setBlendModeBlend() @nogc nothrow;
    ComResult setBlendModeNone() @nogc nothrow;
    ComResult rect(int x, int y, int width, int height) @nogc nothrow;
    ComResult point(int x, int y) @nogc nothrow;
    ComResult line(int startX, int startY, int endX, int endY) @nogc nothrow;
    ComResult lines(Vector2[] linePoints) nothrow;
    ComResult fillRect(int x, int y, int width, int height) @nogc nothrow;
    ComResult getOutputSize(int* width, int* height) @nogc nothrow;
}
