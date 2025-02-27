module api.dm.com.graphics.com_texture;

import api.dm.com.platforms.objects.com_objectable : ComObjectable;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.destroyable : Destroyable;

import api.math.geom2.rect2 : Rect2d;
import api.math.flip : Flip;
import api.dm.com.graphics.com_surface : ComSurface;

enum ComTextureScaleMode
{
    speed,
    quality
}

/**
 * Authors: initkfs
 */
interface ComTexture : ComObjectable, Destroyable
{
nothrow:

    ComResult createUnsafe(void* newPtr);

    ComResult createRGBA32(int width, int height);
    ComResult createABGR32(int width, int height);
    ComResult createARGB32(int width, int height);

    ComResult createMutRGBA32(int width, int height);
    ComResult createMutABGR32(int width, int height);
    ComResult createMutARGB32(int width, int height);

    ComResult createTargetRGBA32(int width, int height);
    ComResult create(ComSurface surface);

    ComResult isCreated(out bool created);

    ComResult getFormat(out uint format);
    ComResult getPixelRowLenBytes(out int pitch);

    ComResult setRendererTarget();
    ComResult restoreRendererTarget();

    ComResult getSize(out int width, out int height);
    ComResult setSize(int newWidth, int newHeight);

    ComResult setBlendMode(ComBlendMode mode);
    ComResult setBlendModeBlend();
    ComResult setBlendModeNone();

    ComResult getOpacity(out double value);
    ComResult setOpacity(double opacity);

    ComResult getScaleMode(out ComTextureScaleMode);
    ComResult setScaleMode(ComTextureScaleMode);

    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a);
    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult lock();
    ComResult lockToSurface(ComSurface buffer);
    ComResult lockToSurface(Rect2d src, ComSurface buffer);
    ComResult unlock();
    ComResult isLocked(out bool locked);

    ComResult update(Rect2d rect, void* pixels, int pitch);

    ComResult getPixels(out void* pixels);
    
    ComResult getPixel(uint x, uint y, out uint* pixel);
    ComResult setPixelColor(uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte aByte);
    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aByte);
    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte);
    ComResult getPixelColor(int x, int y, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte);

    ComResult draw(ComTexture other, Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none);
    ComResult draw(Rect2d textureBounds, Rect2d destBounds, double angle = 0, Flip flip = Flip
            .none);

    ComResult copyToNew(out ComTexture);
    ComResult copyTo(ComTexture toTexture, Rect2d srcRect, Rect2d destRect, double angle = 0, Flip flip = Flip
            .none);
    ComResult copyFrom(ComTexture other, Rect2d srcRect, Rect2d dstRect, double angle = 0, Flip flip = Flip
            .none);

    ComResult nativePtr(out ComNativePtr ptr);
}
