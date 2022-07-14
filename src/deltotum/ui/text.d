module deltotum.ui.text;

import deltotum.display.display_object : DisplayObject;
import deltotum.asset.fonts.font: Font;
import deltotum.hal.sdl.sdl_texture: SdlTexture;
import deltotum.math.rect: Rect;

import std.string: toStringz;

//TODO remove HAL api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Text : DisplayObject
{
    @property string text;

    private
    {
        Font font;
        SdlTexture fontTexture;

        string oldText;
    }

    this(Font font)
    {
        //TODO validate
        this.font = font;
    }

    override void drawContent()
    {
        super.drawContent;
        if (oldText == text && fontTexture !is null)
        {
            updateFont;
            return;
        }

        SDL_Color color = {255, 255, 255, 255};
        //TODO toStringz and GC
        SDL_Surface* fontSurfacePtr = TTF_RenderUTF8_Blended(font.getStruct, text.toStringz, color);
        if (!fontSurfacePtr)
        {
            //TODO return error
            throw new Exception("Unable to render text");
        }

        auto fontTexturePtr = SDL_CreateTextureFromSurface(window.renderer.getStruct, fontSurfacePtr);
        if (!fontTexturePtr)
        {
            throw new Exception("Unable to create texture from text");
        }

        if (fontTexture !is null)
        {
            fontTexture.updateStruct(fontTexturePtr);
        }
        else
        {
            fontTexture = new SdlTexture(fontTexturePtr);
        }
        
        SDL_FreeSurface(fontSurfacePtr);

        updateFont;

        oldText = text;
    }

    protected void updateFont()
    {
        int width, height;
        fontTexture.getSize(&width, &height);
        if (this.width != width)
        {
            this.width = width;
        }

        if (this.height != height)
        {
            this.height = height;
        }
        Rect fontBounds = {0, 0, width, height};
        drawTexture(fontTexture, fontBounds, cast(int) x, cast(int) y, angle);
    }

    override void destroy()
    {
        super.destroy;
        if (fontTexture !is null)
        {
            fontTexture.destroy;
        }
    }

}
