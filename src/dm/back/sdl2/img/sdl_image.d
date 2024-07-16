module dm.back.sdl2.img.sdl_image;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.com.platforms.results.com_result : ComResult;
import dm.com.graphics.com_surface : ComSurface;
import dm.com.graphics.com_image : ComImage;

import dm.back.sdl2.sdl_surface : SdlSurface;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImage : SdlSurface, ComImage
{
    private
    {
        SDL_RWops* rwBuffer;
    }

    this()
    {

    }

    this(SDL_Surface* surfPtr)
    {
        super(surfPtr);
    }

    ComResult load(string path) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        if (path.length == 0)
        {
            return ComResult.error("Image path must not be empty");
        }

        SDL_Surface* imgPtr = IMG_Load(path.toStringz);
        if (!imgPtr)
        {
            return getErrorRes("Unable to load image from: " ~ path);
        }

        ptr = imgPtr;
        return ComResult.success;
    }

    ComResult load(const(void[]) content) nothrow
    {
        if (ptr)
        {
            disposePtr;
        }

        SDL_RWops* rw = SDL_RWFromConstMem(content.ptr, cast(int) content
                .length);
        if (!rw)
        {
            return getErrorRes("Cannot create memory buffer for image");
        }

        rwBuffer = rw;

        SDL_Surface* surfPtr = IMG_Load_RW(rw, 1);
        if (!surfPtr)
        {
            return getErrorRes("Error loading image from buffer");
        }
        this.ptr = surfPtr;
        return ComResult.success;
    }

    ComResult toSurface(out ComSurface surf) nothrow
    {
        assert(ptr);
        import core.utils.types : castSafe;

        auto thisSurf = castSafe!ComSurface(this);
        assert(thisSurf);
        surf = thisSurf;
        return ComResult.success;
    }

    ComResult savePNG(ComSurface surface, string path) nothrow
    {
        //If the file exists, it will be overwritten
        assert(surface, "Surface must not be null");
        assert(path.length > 0, "Image path must not be empty");

        import dm.com.com_native_ptr: ComNativePtr;

        ComNativePtr nativePtr;
        if (const err = surface.nativePtr(nativePtr))
        {
            return err;
        }

        SDL_Surface* surfPtr = nativePtr.castSafe!(SDL_Surface*);

        //TODO unsafe
        const zeroOrErrorCode = IMG_SavePNG(surfPtr, path.toStringz);
        if (zeroOrErrorCode != 0)
        {
            return getErrorRes(zeroOrErrorCode);
        }
        return ComResult.success;
    }

    override bool disposePtr()
    {
        if (rwBuffer)
        {
            // SDL_RWclose(rwBuffer);
            // rwBuffer = null;
        }
        return super.disposePtr;
    }
}
