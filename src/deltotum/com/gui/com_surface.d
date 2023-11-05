module deltotum.com.gui.com_surface;

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.com.lifecycles.destroyable : Destroyable;

import deltotum.math.shapes.rect2d : Rect2d;

/**
 * Authors: initkfs
 */
interface ComSurface : Destroyable
{
    ComResult createRGBSurface(uint flags = 0, int width = 10, int height = 10, int depth = 32,
        uint rmask = 0, uint gmask = 0, uint bmask = 0, uint amask = 0);

    ComResult createRGBSurfaceFrom(void* pixels, int width, int height, int depth, int pitch,
        uint rmask, uint gmask, uint bmask, uint amask);

    ComResult resize(int newWidth, int newHeight, out bool isResized);

    ComResult lock();

    ComResult unlock();

    inout(void*) pixels() inout @nogc nothrow @safe;

    uint* pixel(int x, int y);

    void setPixel(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a);
    void setPixel(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a);

    int pitch() inout @nogc nothrow @safe;

    int width() @nogc nothrow @safe;
    int height() @nogc nothrow @safe;

    ComResult nativePtr(out void* ptr) nothrow;

}
