module dm.com.graphics.com_surface;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;
import dm.com.graphics.com_blend_mode : ComBlendMode;

import dm.math.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
interface ComSurface : Destroyable
{
    ComResult createRGBSurface(double width, double height);

    ComResult createRGBSurface(uint flags, int width, int height, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0);

    ComResult createRGBSurfaceFrom(void* pixels, int width, int height, int depth, int pitch,
        uint rmask, uint gmask, uint bmask, uint amask);

    ComResult loadFromPtr(void* ptr) nothrow;

    ComResult resize(int newWidth, int newHeight, out bool isResized);

    ComResult lock();

    ComResult unlock();

    ComResult setBlendMode(ComBlendMode mode);
    ComResult getBlendMode(out ComBlendMode mode);

    inout(void*) pixels() inout @nogc nothrow @safe;

    uint* getPixel(int x, int y) nothrow;

    //TODO move RGBA color to math?
    import std.typecons: Tuple;

    void getPixels(scope bool delegate(size_t, size_t, ubyte, ubyte, ubyte, ubyte) onXYRGBAIsContinue);
    void getPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    Tuple!(ubyte, ubyte, ubyte, ubyte)[][] getPixels();
    void setPixels(Tuple!(ubyte, ubyte, ubyte, ubyte)[][] buff);
    void setPixels(scope bool delegate(size_t, size_t, out Tuple!(ubyte, ubyte, ubyte, ubyte)) onXYRGBAIsContinue);

    void setPixelRGBA(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a);
    void setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a) nothrow;
    void getPixelRGBA(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow;

    int pitch() inout @nogc nothrow @safe;

    int width() @nogc nothrow @safe;
    int height() @nogc nothrow @safe;

    ComResult blit(Rect2d srcRect, ComSurface dst, Rect2d dstRect);
    ComResult blit(ComSurface dst, Rect2d dstRect);
    ComResult getBlitAlphaMod(out int mod);
    ComResult setBlitAlhpaMod(int mod);

    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult nativePtr(out void* ptr) nothrow;

}
