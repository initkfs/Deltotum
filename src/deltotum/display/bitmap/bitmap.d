module deltotum.display.bitmap.bitmap;

import std.stdio;

import deltotum.display.display_object : DisplayObject;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;

import bindbc.sdl;

//TODO remove duplication with animation bitmap, but it's not clear what code would be required
class Bitmap : DisplayObject
{
    protected
    {
        SdlTexture texture;
        SdlRenderer renderer;
    }

    this(SdlRenderer renderer)
    {
        this.renderer = renderer;
    }

    void load(string path)
    {
        auto image = new SdlImage(path);
        texture = new SdlTexture;
        texture.fromRenderer(renderer, image);
        int width;
        int height;
        int result = texture.getSize(&width, &height);
        if (result != 0)
        {
            string error = "Unable to load image from " ~ path;
            if (const err = texture.getError)
            {
                error ~= err;
            }
            throw new Exception(error);
        }

        this.width = width;
        this.height = height;

        image.destroy;
    }

    void drawImage(int x, int y, int width, int height, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        SDL_Rect srcRect;
        SDL_Rect destRect;

        srcRect.x = 0;
        srcRect.y = 0;
        srcRect.w = width;
        destRect.w = width;
        srcRect.h = height;
        destRect.h = height;
        destRect.x = x;
        destRect.y = y;

        SDL_Point center = {0, 0};
        renderer.copyEx(texture, &srcRect, &destRect, 0, &center, flip);
    }

    override void draw()
    {
        super.draw;
        //or double?
        drawImage(cast(int) x, cast(int) y, cast(int) width, cast(int) height);
    }

    override void update(double delta)
    {
        super.update(delta);
    }

    override void destroy()
    {
        super.destroy;
        texture.destroy;
    }
}
