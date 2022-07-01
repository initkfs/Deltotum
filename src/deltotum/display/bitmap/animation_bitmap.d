module deltotum.display.bitmap.animation_bitmap;

import deltotum.display.display_object : DisplayObject;

//TODO extract interfaces
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.hal.sdl.img.sdl_image : SdlImage;

import bindbc.sdl;

class AnimationBitmap : DisplayObject
{
    private
    {
        SdlTexture texture;
        SdlRenderer renderer;
        int currentFrame;
        int frameWidth;
        int frameHeight;
        int frameCount;
    }

    this(SdlRenderer renderer, int frameWidth, int frameHeight, int frameCount)
    {
        this.renderer = renderer;
        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;
        this.frameCount = frameCount;
    }

    void load(string path)
    {
        auto image = new SdlImage(path);
        texture = new SdlTexture;
        texture.fromRenderer(renderer, image);
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

    void drawFrame(int x, int y, int width, int height, int currentRow, int currentFrame, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        SDL_Rect srcRect;
        SDL_Rect destRect;
        srcRect.x = width * currentFrame;
        srcRect.y = height * (currentRow - 1);

        srcRect.w = width;
        destRect.w = width;

        srcRect.h = width;
        destRect.h = height;

        destRect.x = x;
        destRect.y = y;

        SDL_Point center = {0, 0};
        renderer.copyEx(texture, &srcRect, &destRect, 0, &center, flip);
    }

    override void draw()
    {
        super.draw;
        drawFrame(x, y, frameWidth, frameHeight, 1, currentFrame);
    }

    override void update()
    {
        super.update;
        currentFrame = int(((SDL_GetTicks() / frameWidth) % frameCount));
    }

    override void destroy()
    {
        super.destroy;
        texture.destroy;
    }
}
