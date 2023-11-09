module deltotum.sys.sdl.img.sdl_image;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.com.platforms.results.com_result : ComResult;
import deltotum.com.graphics.com_surface : ComSurface;
import deltotum.com.graphics.com_image : ComImage;

import deltotum.sys.sdl.sdl_surface : SdlSurface;

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
        surf = cast(ComSurface) this;
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
