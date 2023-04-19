module deltotum.sdl.img.sdl_image;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.sdl.sdl_surface : SdlSurface;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImage : SdlSurface
{

    string path;

    this(string path, SdlSurface screenSurface = null)
    {
        super();
        this.path = path;

        SDL_Surface* imgPtr = IMG_Load(path.toStringz);
        if (imgPtr is null)
        {
            import std.format : format;

            string error = format("Unable to load image from: %s.", path);
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }

        if (screenSurface !is null)
        {
            auto oldSurface = imgPtr;
            //TODO check errors?
            if(const err = convertSurfacePtr(imgPtr, imgPtr, screenSurface.getPixelFormat)){
                throw new Exception(err.toString);
            }
            oldSurface.destroy;
        }

        this.ptr = imgPtr;
    }

    this(SDL_Surface* ptr)
    {
        super(ptr);
    }
}
