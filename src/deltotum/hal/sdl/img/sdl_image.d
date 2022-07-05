module deltotum.hal.sdl.img.sdl_image;

import deltotum.hal.sdl.sdl_surface : SdlSurface;

import std.string : toStringz, fromStringz;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlImage : SdlSurface
{

    @property string path;

    this(string path, SdlSurface screenSurface = null)
    {
        super();
        this.path = path;

        SDL_Surface* ptr = IMG_Load(path.toStringz);
        if (ptr is null)
        {
            import std.format : format;

            string error = format("Unable to load image from: %s.", path);
            if (const err = getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }

        auto surface = ptr;
        if (screenSurface !is null)
        {
            auto oldSurface = surface;
            //TODO check errors?
            surface = convertSurfacePtr(surface, screenSurface.getPixelFormat);
            oldSurface.destroy;
        }

        this.ptr = surface;
    }

    this(SDL_Surface* ptr)
    {
        super(ptr);
    }
}
