module deltotum.sys.freeimage.freeimage_bitmap;

import deltotum.sys.freeimage.base.freeimage_ptr_manager : FreeImagePtrManager;

import std.string : toStringz, fromStringz;

import bindbc.freeimage;

class FreeImageBitmap : FreeImagePtrManager!(FIBITMAP)
{

    this(string path)
    {
        //TODO check path
        FREE_IMAGE_FORMAT filetype = FreeImage_GetFileType(path.toStringz, 0);
        ptr = FreeImage_Load(filetype, path.toStringz, 0);
        if (!ptr)
        {
            throw new Exception("Image loading error from " ~ path);
        }

        //TODO coordinates?
        FreeImage_FlipVertical(ptr);
    }

    override bool destroyPtr() nothrow @nogc
    {
        if (!ptr)
        {
            return false;
        }

        FreeImage_Unload(ptr);
        return true;
    }

    BYTE* bits()
    {
        return FreeImage_GetBits(ptr);
    }

    uint width()
    {
        return FreeImage_GetWidth(ptr);
    }

    uint height()
    {
        return FreeImage_GetHeight(ptr);
    }

    uint bpp()
    {
        return FreeImage_GetBPP(ptr);
    }

    uint pitch()
    {
        return FreeImage_GetPitch(ptr);
    }

    uint redMask()
    {
        return FreeImage_GetRedMask(ptr);
    }

    uint greenMask()
    {
        return FreeImage_GetGreenMask(ptr);
    }

    uint blueMask()
    {
        return FreeImage_GetBlueMask(ptr);
    }

}
