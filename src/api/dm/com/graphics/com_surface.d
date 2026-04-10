module api.dm.com.graphics.com_surface;

import api.dm.com.ptrs.com_pointerable : ComPointerable;
import api.dm.com.com_result : ComResult;
import api.dm.com.com_error_manageable : ComErrorManageable;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.ptrs.com_native_ptr : ComNativePtr;

import api.math.geom2.rect2 : Rect2f;

/**
 * Authors: initkfs
 */
interface ComSurface : ComPointerable, ComErrorManageable
{
    void onPixelsRGBA(scope bool delegate(size_t x, size_t y, uint* pixel) onXYPixelIsContinue) @trusted;

    bool getPixelsRGBA(
        scope bool delegate(size_t x, size_t y, ubyte r, ubyte g, ubyte b, ubyte a) onXYRGBAIsContinue
    ) @trusted;

    bool setPixelsRGBA(
        scope bool delegate(size_t x, size_t y, ref ubyte r, ref ubyte g, ref ubyte b, ref ubyte a) onXYRGBAIsContinue
    ) @trusted;

nothrow:

    ComResult create(int width, int height, uint format);
    ComResult createRGBA32(int width, int height);
    ComResult createBGRA32(int width, int height);
    ComResult createRGB24(int width, int height);
    ComResult createRaw(void* ptr) nothrow;
    ComResult create(ComNativePtr ptr) nothrow;

    uint getFormat();
    int getWidth();
    int getHeight();
    void getSize(out int w, out int h);

    //pitch = image-width × bytes-per-pixel + padding-between-rows
    int getPitch();

    ComResult resize(int newWidth, int newHeight, out bool isResized);
    ComResult rotateTo(float angleDeg, ComSurface target);

    ComResult copyTo(ComSurface dst);
    ComResult copyTo(ComSurface dst, Rect2f dstRect);
    ComResult copyTo(Rect2f srcRect, ComSurface dst, Rect2f dstRect);

    ComResult getCopyAlphaMod(out int mod);
    ComResult setCopyAlphaMod(int mod);

    ComResult lock();
    ComResult unlock();

    ComResult fill(ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult setBlendMode(ComBlendMode mode);
    ComResult getBlendMode(out ComBlendMode mode);

    void* pixels();
    ComResult getPixelsRGBA(out void* pixels);
   
    bool getPixel(int x, int y, out uint* pixel);
    bool getPixel(uint* pixel, out ubyte r, out ubyte g, out ubyte b, out ubyte a);

    bool setPixel(int x, int y, ubyte r, ubyte g, ubyte b, ubyte a);
    bool setPixel(uint* pixel, ubyte r, ubyte g, ubyte b, ubyte a);
    
    ComResult setPixelIsTransparent(bool isTransparent, ubyte r, ubyte g, ubyte b, ubyte a);

    ComResult convert(int format);

    ComResult saveBMP(const(char)[] file);
    ComResult loadBMP(const(char)[] file);
}
