module deltotum.ui.controls.text;

import deltotum.ui.controls.control : Control;
import deltotum.asset.fonts.font : Font;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.math.rect : Rect;
import deltotum.ui.theme.theme : Theme;

import std.string : toStringz;

//TODO remove HAL api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Text : Control
{
    @property string text = "text";

    private
    {
        Font font;
        SdlTexture fontTexture;
        string oldText;
    }

    this(Theme theme)
    {
        super(theme);
        //TODO validate
        this.font = theme.defaultFontMedium;
    }

    override void create()
    {
        backgroundFactory = null;
        super.create;
        updateFont;
    }

    override void drawContent()
    {
        Rect textureBounds = {0, 0, width, height};
        //TODO to int
        drawTexture(fontTexture, textureBounds, cast(int) x, cast(int) y, angle);
    }

    protected void updateFont()
    {
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

        int width, height;
        fontTexture.getSize(&width, &height);
        this.width = width;
        this.height = height;

        SDL_FreeSurface(fontSurfacePtr);
    }

    override void update(double delta)
    {
        if (oldText == text && fontTexture !is null)
        {
            return;
        }
        updateFont;
        oldText = text;
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
