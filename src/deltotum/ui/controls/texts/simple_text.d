module deltotum.ui.controls.texts.simple_text;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.asset.fonts.font : Font;
import deltotum.platform.sdl.sdl_texture : SdlTexture;
import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.maths.shapes.rect2d : Rect2d;
import deltotum.toolkit.graphics.colors.rgba : RGBA;

import std.string : toStringz;

//TODO remove HAL api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SimpleText : Control
{
    string text;

    private
    {
        Font font;
        Texture fontTexture;
        string oldText;
    }

    this(string text = "text")
    {
        super();
        //TODO validate
        this.text = text;
    }

    override void create()
    {
        this.font = graphics.theme.defaultFontMedium;
        backgroundFactory = null;
        super.create;
        updateFont;
    }

    override void drawContent()
    {
        fontTexture.x = x;
        fontTexture.y = y;
        fontTexture.drawContent;
    }

    protected void updateFont(RGBA color = RGBA.white)
    {
        auto fontSurface = font.renderSurface(text, color);
        //TODO this.fontTexture !is null
        fontTexture = new Texture();
        fontTexture.loadFromSurface(fontSurface);
        build(fontTexture);

        fontSurface.destroy;

        const bounds = fontTexture.bounds;
        this.width = bounds.width;
        this.height = bounds.height;
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
