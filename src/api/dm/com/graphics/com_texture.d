module api.dm.com.graphics.com_texture;

import api.dm.com.objects.com_objectable : ComObjectable;
import api.dm.com.com_result : ComResult;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.com_error_manageable : ComErrorManageable;

import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2: Vec2f;
import api.math.pos2.flip : Flip;
import api.dm.com.graphics.com_surface : ComSurface;

enum ComTextureScaleMode
{
    speed,
    quality,
    pixelart
}

enum ComTextureWrapMode
{
    none,
    wrap, //Wrapping is enabled if texture coordinates are outside [0, 1], this is the default
    clamp, //Texture coordinates are clamped to the [0, 1] range
    tiled //The texture is repeated
}

/**
 * Authors: initkfs
 */
interface ComTexture : ComObjectable, ComDestroyable, ComErrorManageable
{
nothrow:

    ComResult createUnsafe(void* newPtr);

    ComResult createRGBA32(int width, int height);
    ComResult createABGR32(int width, int height);
    ComResult createARGB32(int width, int height);

    ComResult createMutRGBA32(int width, int height);
    ComResult createMutBGRA32(int width, int height);
    ComResult createMutABGR32(int width, int height);
    ComResult createMutARGB32(int width, int height);

    ComResult createMutYV(int width, int height);

    ComResult createTargetRGBA32(int width, int height);
    ComResult create(ComSurface surface);

    ComResult isCreating(out bool created);

    ComResult getFormat(out uint format);
    ComResult getPixelRowLenBytes(out int pitch);

    ComResult setRenderTarget();
    ComResult restoreRenderTarget();

    ComResult getSize(out int width, out int height);
    ComResult setSize(int newWidth, int newHeight);

    ComResult setBlendMode(ComBlendMode mode);
    ComResult setBlendModeBlend();
    ComResult setBlendModeNone();

    ComResult getOpacity(out float value);
    ComResult setOpacity(float opacity);

    ComResult getScaleMode(out ComTextureScaleMode);
    ComResult setScaleMode(ComTextureScaleMode);

    ComResult getColor(out ubyte r, out ubyte g, out ubyte b, out ubyte a);
    ComResult setColor(ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult lock();
    ComResult lockToSurface(ComSurface buffer);
    ComResult lockToSurface(Rect2f src, ComSurface buffer);
    ComResult unlock();
    ComResult isLocked(out bool locked);

    ComResult fill(ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult update(Rect2f rect, void* pixels, int pitch);

    ComResult getPixels(out void* pixels);

    ComResult getPixel(uint x, uint y, out uint* pixel);
    ComResult setPixelColor(uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte aByte);
    ComResult setPixelColor(uint* ptr, ubyte r, ubyte g, ubyte b, ubyte aByte);
    ComResult getPixelColor(uint* ptr, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte);
    ComResult getPixelColor(int x, int y, out ubyte r, out ubyte g, out ubyte b, out ubyte aByte);

    bool draw(ComTexture other, Rect2f textureBounds, Rect2f destBounds, float angle = 0, Flip flip = Flip
            .none, Vec2f rotateCenter = Vec2f.zero);
    bool draw(Rect2f textureBounds, Rect2f destBounds, float angle = 0, Flip flip = Flip
            .none, Vec2f rotateCenter = Vec2f.zero);

    ComResult copyToNew(out ComTexture);
    ComResult copyTo(ComTexture toTexture, Rect2f srcRect, Rect2f destRect, float angle = 0, Flip flip = Flip
            .none);
    ComResult copyFrom(ComTexture other, Rect2f srcRect, Rect2f dstRect, float angle = 0, Flip flip = Flip
            .none);

    ComResult nativePtr(out ComNativePtr ptr);
    ComResult nativePtr(out void* tptr);
}
