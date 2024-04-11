module dm.com.graphics.com_surface;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.destroyable : Destroyable;
import dm.com.graphics.com_blend_mode : ComBlendMode;
import dm.com.com_native_ptr: ComNativePtr;

import dm.math.rect2d : Rect2d;

import std.typecons : Tuple;

/**
 * Authors: initkfs
 */
interface ComSurface : Destroyable
{
    ComResult getPixels(
        scope bool delegate(size_t, size_t, ubyte, ubyte, ubyte, ubyte) onXYRGBAIsContinue
    );

    ComResult setPixels(
        scope bool delegate(size_t, size_t, out Tuple!(ubyte, ubyte, ubyte, ubyte)) onXYRGBAIsContinue
    );

nothrow:

    ComResult createRGB(int width, int height);
    ComResult createRGB(uint flags, int width, int height, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0);
    ComResult createRGB(void* pixels, int width, int height, int depth, int pitch,
        uint rmask, uint gmask, uint bmask, uint amask);
    ComResult createFromPtr(void* ptr) nothrow;
    ComResult resize(int newWidth, int newHeight, out bool isResized);
    ComResult lock();
    ComResult unlock();
    ComResult setBlendMode(ComBlendMode mode);
    ComResult getBlendMode(out ComBlendMode mode);
    ComResult getPixel(int x, int y, out uint* pixel);
    ComResult getPixels(out void* pixels);
    ComResult getPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    ComResult getPixels(out Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    ComResult setPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    ComResult setPixelRGBA(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult getPixelRGBA(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a);
    ComResult getPitch(out int pitch);
    ComResult getFormat(out uint format);
    ComResult getWidth(out int w);
    ComResult getHeight(out int h);
    ComResult blit(Rect2d srcRect, ComSurface dst, Rect2d dstRect);
    ComResult blit(ComSurface dst, Rect2d dstRect);
    ComResult getBlitAlphaMod(out int mod);
    ComResult setBlitAlhpaMod(int mod);
    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult nativePtr(out ComNativePtr ptr) nothrow;
}
