module dm.com.graphics.com_texture;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.lifecycles.destroyable : Destroyable;

import dm.math.shapes.rect2d : Rect2d;
import dm.math.geom.flip : Flip;
import dm.com.graphics.com_surface : ComSurface;

/**
 * Authors: initkfs
 */
interface ComTexture : Destroyable
{
    bool isCreated() nothrow;
    bool isLocked() nothrow;
    ComResult fromSurface(ComSurface surface) nothrow;
    ComResult recreatePtr(void* newPtr) nothrow;

    ComResult getSize(out int width, out int height) nothrow;

    ComResult setRendererTarget() nothrow;

    ComResult resetRendererTarget() nothrow;

    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow;
    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a) nothrow;

    ComResult createMutRGBA32(int width, int height) nothrow;
    ComResult createImmutRGBA32(int width, int height) nothrow;
    ComResult createTargetRGBA32(int width, int height) nothrow;

    ComResult lock() nothrow;
    ComResult unlock() nothrow;

    ComResult getPixel(uint x, uint y, out uint* pixel) nothrow;
    ComResult setPixelColor(uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte aByte) nothrow;
    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aByte) nothrow;
    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte) nothrow;
    ComResult getPixelColor(int x, int y, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte) nothrow;

    ComResult setBlendMode(ComBlendMode mode) nothrow;
    ComResult setBlendModeBlend() nothrow;
    ComResult setBlendModeNone() nothrow;

    ComResult resize(double newWidth, double newHeight) nothrow;

    ComResult changeOpacity(double opacity) nothrow;

    ComResult draw(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none);

    ComResult copy(out ComTexture);

    double opacity() nothrow;
    void opacity(double opacity) nothrow;

    ComResult nativePtr(out void* ptr) nothrow;

}
