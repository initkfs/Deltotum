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
    string path;

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

        SDL_Surface* imgPtr = IMG_Load(path.toStringz);
        if (imgPtr is null)
        {
            import std.format : format;

            string error = "Unable to load image from: " ~ path;
            if (const err = getError)
            {
                error ~= err;
            }
        }
        ptr = imgPtr;
        return ComResult.success;
    }

    ComResult load(const(void[]) content) nothrow
    {
        import std.string : toStringz;

        if (ptr)
        {
            disposePtr;
        }

        SDL_RWops* rw = SDL_RWFromConstMem(content.ptr, cast(int) content
                .length);
        if (!rw)
        {
            return ComResult.error("Cannot create memory buffer for image");
        }
        rwBuffer = rw;

        SDL_Surface* surfPtr = IMG_Load_RW(rw, 1);
        if (!surfPtr)
        {
            return ComResult.error("Image loading error: " ~ IMG_GetError().fromStringz.idup);
        }
        this.ptr = surfPtr;
        return ComResult.success;
    }

    ComResult toSurface(out ComSurface surf) nothrow
    {
        assert(ptr);
        import dm.core.utils.type_util : castSafe;

        surf = this.castSafe!ComSurface;
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
