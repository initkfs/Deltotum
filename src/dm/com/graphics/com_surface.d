module dm.com.graphics.com_surface;

import dm.com.platforms.results.com_result : ComResult;
import dm.com.lifecycles.destroyable : Destroyable;

import dm.math.shapes.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
interface ComSurface : Destroyable
{
    ComResult createRGBSurface(uint flags = 0, int width = 10, int height = 10, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0);

    ComResult createRGBSurfaceFrom(void* pixels, int width, int height, int depth, int pitch,
        uint rmask, uint gmask, uint bmask, uint amask);

    ComResult loadFromPtr(void* ptr) nothrow;

    ComResult resize(int newWidth, int newHeight, out bool isResized);

    ComResult lock();

    ComResult unlock();

    inout(void*) pixels() inout @nogc nothrow @safe;

    uint* getPixel(int x, int y) nothrow;

    void setPixelRGBA(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a);
    void setPixelRGBA(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a) nothrow;
    void getPixelRGBA(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a) nothrow;

    int pitch() inout @nogc nothrow @safe;

    int width() @nogc nothrow @safe;
    int height() @nogc nothrow @safe;

    ComResult nativePtr(out void* ptr) nothrow;

}
