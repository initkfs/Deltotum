module api.dm.com.graphic.com_surface;

import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.destroyable : Destroyable;
import api.dm.com.graphic.com_blend_mode : ComBlendMode;
import api.dm.com.com_native_ptr : ComNativePtr;

import api.math.geom2.rect2 : Rect2d;

import std.typecons : Tuple;

/**
 * Authors: initkfs
 */
interface ComSurface : Destroyable
{
    ComResult getPixels(
        scope bool delegate(size_t, size_t, ubyte, ubyte, ubyte, ubyte) onXYRGBAIsContinue
    ) @trusted;

    ComResult setPixels(
        scope bool delegate(size_t, size_t, out Tuple!(ubyte, ubyte, ubyte, ubyte)) onXYRGBAIsContinue
    ) @trusted;

nothrow:

    ComResult createRGBA32(int width, int height);
    ComResult createARGB32(int width, int height);
    ComResult createABGR32(int width, int height);
    ComResult createBGRA32(int width, int height);
    ComResult createUnsafe(void* ptr) nothrow;
    ComResult create(ComNativePtr ptr) nothrow;

    //pitch = image-width × bytes-per-pixel + padding-between-rows
    ComResult getPixelRowLenBytes(out int pitch);
    ComResult getFormat(out uint format);
    ComResult getWidth(out int w);
    ComResult getHeight(out int h);

    ComResult resize(int newWidth, int newHeight, out bool isResized);

    ComResult copyTo(ComSurface dst);
    ComResult copyTo(ComSurface dst, Rect2d dstRect);
    ComResult copyTo(Rect2d srcRect, ComSurface dst, Rect2d dstRect);

    ComResult getCopyAlphaMod(out int mod);
    ComResult setCopyAlphaMod(int mod);

    ComResult lock();
    ComResult unlock();

    ComResult fill(ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult setBlendMode(ComBlendMode mode);
    ComResult getBlendMode(out ComBlendMode mode);

    ComResult getPixel(int x, int y, out uint* pixel);
    ComResult getPixels(out void* pixels);
    ComResult getPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    ComResult getPixels(out Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    ComResult getPixelRGBA(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a);

    ComResult setPixelRGBA(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a);
    ComResult setPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);

    ComResult nativePtr(out ComNativePtr ptr);
}
