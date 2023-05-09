module deltotum.kit.sprites.images.bitmaps.bitmap;

//TODO remove sys
import deltotum.sys.freeimage.freeimage_bitmap : FreeImageBitmap;

class Bitmap
{
    protected
    {
        FreeImageBitmap _bitmap;
    }

    void load(string path)
    {
        //TODO _bitmap !is null
        _bitmap = new FreeImageBitmap(path);
    }

    ubyte* bits()
    {
        return cast(ubyte*) _bitmap.bits;
    }

    int width()
    {
        return _bitmap.width;
    }

    int height()
    {
        return _bitmap.height;
    }

    uint bpp()
    {
        return _bitmap.bpp;
    }

    uint pitch()
    {
        return _bitmap.pitch;
    }

    uint redMask()
    {
        return _bitmap.redMask;
    }

    uint greenMask()
    {
        return _bitmap.greenMask;
    }

    uint blueMask()
    {
        return _bitmap.blueMask;
    }
}
