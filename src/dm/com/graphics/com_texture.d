module dm.com.graphics.com_texture;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.lifecycles.destroyable : Destroyable;

import dm.math.rect2d : Rect2d;
import dm.math.flip : Flip;
import dm.com.graphics.com_surface : ComSurface;

enum ComTextureScaleMode
{
    speed,
    balance,
    quality
}

/**
 * Authors: initkfs
 */
interface ComTexture : Destroyable
{
nothrow:

    ComResult isCreated(out bool created);
    ComResult isLocked(out bool locked);
    ComResult createMutARGB8888(int width, int height);
    ComResult createMutRGBA32(int width, int height);
    ComResult createImmutRGBA32(int width, int height);
    ComResult createTargetRGBA32(int width, int height);
    ComResult createFromSurface(ComSurface surface);
    ComResult recreatePtr(void* newPtr);
    ComResult getSize(out int width, out int height);
    ComResult setRendererTarget();
    ComResult resetRendererTarget();
    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a);
    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult lock();
    ComResult unlock();
    ComResult getFormat(out uint format);
    ComResult getPitch(out int pitch);
    ComResult getPixels(out void* pixels);
    ComResult update(Rect2d rect, void* pixels, int pitch);
    ComResult getPixel(uint x, uint y, out uint* pixel);
    ComResult setPixelColor(uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte aByte);
    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aByte);
    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte);
    ComResult getPixelColor(int x, int y, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte);
    ComResult setBlendMode(ComBlendMode mode);
    ComResult setBlendModeBlend();
    ComResult setBlendModeNone();
    ComResult resize(double newWidth, double newHeight);
    ComResult draw(ComTexture other, Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none);
    ComResult draw(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none);
    ComResult copy(out ComTexture);
    ComResult copyTo(ComTexture toTexture, Rect2d srcRect, Rect2d destRect, double angle = 0, Flip flip = Flip
            .none);
    ComResult copyFrom(ComTexture other, Rect2d srcRect, Rect2d dstRect, double angle = 0, Flip flip = Flip
            .none);
    ComResult getOpacity(out double value);
    ComResult setOpacity(double opacity);
    ComResult setScaleMode(ComTextureScaleMode);
    ComResult getScaleMode(out ComTextureScaleMode);
    ComResult nativePtr(out void* ptr);
}
